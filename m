From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Mon, 1 Sep 2008 19:05:14 +0200
Message-ID: <20080901170514.GA12275@pest>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:55426 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbYIARFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 13:05:17 -0400
Content-Disposition: inline
In-Reply-To: <20080901170101.GA12236@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 01, 2008 at 07:01:01PM +0200, Bernhard Schmidt wrote:

> >  If you can pick up the exact arguments when it's happening
> > via strace and send those here, that may help, but I wouldn't
> > expect those to be incorrect from ping6 only some of the
> > time...

BTW, these are the sendmsg() calls from ripngd (strace attached to the
running process):

sendmsg(5, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(521), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\2\1\0\0 \1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0 \1"..., 24}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)

Regards,
Bernhard
