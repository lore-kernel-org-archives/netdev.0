From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Fri, 21 Apr 2017 14:47:21 -0600
Message-ID: <f25a8af5-cbdc-cdbf-29e2-de8acf5dbd9b@cumulusnetworks.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
 <3bdb570e-4d7d-6e5c-3270-0bf0064ef73a@cumulusnetworks.com>
 <a4360e77-4386-2760-0b7e-72a21b3aad99@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34310 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162498AbdDUUrY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:47:24 -0400
Received: by mail-io0-f170.google.com with SMTP id a103so134120291ioj.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 13:47:23 -0700 (PDT)
In-Reply-To: <a4360e77-4386-2760-0b7e-72a21b3aad99@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/17 11:44 AM, Robert Shearman wrote:
> 
> Can you send me some more details of your testing?

It's a shell script that runs a long list of combinations of client,
server and local traffic for ipv4 and ipv6 with addresses on the
external interface, the vrf device and 127.0.0.1 on the VRF device and
link local and mcast addresses for IPv6. Tests are run for icmp, tcp and
udp - and includes negative testing to verify tcp resets or icmp
unreachables are properly sent and received. There are so many
combinations. And then you have to check tcp_l3mdev_accept = {0,1} and
udp_l3mdev_accept = {0,1}.

For your 'main table' vrf run through the different combinations and
check IPv6 linklocal addressing to.
