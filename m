From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Thu, 20 Dec 2012 09:40:17 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70FB@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <20121218125735.GG27746@casper.infradead.org> <50D09897.8030508@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com> <20121218171103.GI27746@casper.infradead.org> <AE90C24D6B3A694183C094C60CF0A2F6026B70F6@saturn3.aculab.com> <20121219172012.GC6975@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <nicolas.dichtel@6wind.com>, <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53292 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752069Ab2LTJqn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 04:46:43 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10574-10 for <netdev@vger.kernel.org>;
 Thu, 20 Dec 2012 09:46:39 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121219172012.GC6975@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I think:
> > 1) Alignment is only needed on systems that have 'strict alignment'
> >    requirements (maybe disable for testing?)
> 
> Right, what about mixed 32bit/64bit environments?

Support for i386 user binaries on amd64 kernels
is an entirely different problem!
That, typically, requires the kernel to know that
the application is 32bit and use separate structures
where the 64bit items have the aligned(32) attribute.

	David
