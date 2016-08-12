From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Do not keep IPv6 addresses when IPv6 is
 disabled
Date: Fri, 12 Aug 2016 11:01:43 -0600
Message-ID: <069293e2-0c21-3439-edec-5482f19b79d2@cumulusnetworks.com>
References: <1470999758-11535-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32844 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbcHLRBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 13:01:45 -0400
Received: by mail-pf0-f177.google.com with SMTP id y134so10743620pfg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 10:01:45 -0700 (PDT)
In-Reply-To: <1470999758-11535-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/16 5:02 AM, Mike Manning wrote:
> If IPv6 is disabled when the option is set to keep IPv6
> addresses on link down, userspace is unaware of this as
> there is no such indication via netlink. The solution is to
> remove the IPv6 addresses in this case, which results in
> netlink messages indicating removal of addresses in the
> usual manner. This fix also makes the behavior consistent
> with the case of having IPv6 disabled first, which stops
> IPv6 addresses from being added.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---


Acked-by: David Ahern <dsa@cumulusnetworks.com>
