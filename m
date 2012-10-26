From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next v2 2/5] rtnl/ipv6: use netconf msg to advertise forwarding status
Date: Fri, 26 Oct 2012 10:03:54 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7070@saturn3.aculab.com>
References: <20121023.132940.1732325493436273627.davem@davemloft.net><1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com><1351094579-3911-3-git-send-email-nicolas.dichtel@6wind.com> <20121026.021830.1470799532580844849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36466 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752156Ab2JZJNI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 05:13:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19964-09 for <netdev@vger.kernel.org>;
 Fri, 26 Oct 2012 10:13:03 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20121026.021830.1470799532580844849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static inline int inet6_netconf_msgsize_devconf(int type)
> 
> Outside of header files, we don't add explicit inlines, we let
> the compiler decide.

Hmmm.... In my experience it makes bad decisions,
even for static functions that are only called once.
And yes, I have checked that the inlined code is smaller
and faster.

	David
