From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: add ip to interface as primary ip address, not secondary ip
 when there is alreadly primary ip?
Date: Fri, 20 Sep 2013 02:28:21 +0000 (UTC)
Message-ID: <l1gbs4$da2$1@ger.gmane.org>
References: <CAK3+h2zPYYLaVs-WhHFaDhOsnLBB7m8vDvkTj5a16FUJ02i4KA@mail.gmail.com>
 <l1as5j$7cs$1@ger.gmane.org>
 <CAK3+h2yWjswp6qrToMPbrQyuyCKkh5Yuuo6TeX8VhGQCGpCecw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37400 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067Ab3ITC2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 22:28:44 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VMqSX-0006nt-Sc
	for netdev@vger.kernel.org; Fri, 20 Sep 2013 04:28:41 +0200
Received: from 27.200.201.131 ([27.200.201.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 04:28:41 +0200
Received: from xiyou.wangcong by 27.200.201.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 04:28:41 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Sep 2013 at 16:54 GMT, Vincent Li <vincent.mc.li@gmail.com> wrote:
> thanks for the pointer
>
> 'ip addr' indeed has flag IFA_F_SECONDARY for this, but it is not
> available for 'ip addr add', so I made a simple patch for iproute2
> ip/ipaddress.c as below:

% git grep secondary ip/ipaddress.c
ip/ipaddress.c: fprintf(stderr, "FLAG  := [ permanent | dynamic |
secondary | primary |\n");
ip/ipaddress.c:                 fprintf(fp, "secondary ");
ip/ipaddress.c:static int print_addrinfo_secondary(const struct
sockaddr_nl *who,
ip/ipaddress.c:                         .filter =
print_addrinfo_secondary,
ip/ipaddress.c:         } else if (strcmp(*argv, "secondary") == 0 ||
