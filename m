From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] net: ipv6: Always leave anycast and multicast groups
 on link down
Date: Fri, 22 Jul 2016 11:37:26 -0600
Message-ID: <ff13cbf6-4719-1858-33db-5f74bc1d8435@cumulusnetworks.com>
References: <1469208731-1085-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36422 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbcGVRh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 13:37:28 -0400
Received: by mail-pf0-f172.google.com with SMTP id h186so43288714pfg.3
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:37:27 -0700 (PDT)
In-Reply-To: <1469208731-1085-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/16 11:32 AM, Mike Manning wrote:
> Default kernel behavior is to delete IPv6 addresses on link
> down, which entails deletion of the multicast and the
> subnet-router anycast addresses. These deletions do not
> happen with sysctl setting to keep global IPv6 addresses on
> link down, so every link down/up causes an increment of the
> anycast and multicast refcounts. These bogus refcounts may
> stop these addrs from being removed on subsequent calls to
> delete them. The solution is to leave the groups for the
> multicast and subnet anycast on link down for the callflow
> when global IPv6 addresses are kept.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>


Acked-by: David Ahern <dsa@cumulusnetworks.com>
