From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Thu, 16 May 2013 09:24:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B723D@saturn3.aculab.com>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com><20130515095322.275c9b2f@nehalam.linuxnetplumber.net>	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com> <20130515104308.5de3e852@nehalam.linuxnetplumber.net> <OF80FDF86D.7A293781-ON85257B6C.0061CCF7-85257B6C.0063F69C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>,
	<netdev-owner@vger.kernel.org>
To: "David Stevens" <dlstevens@us.ibm.com>,
	"Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57624 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752911Ab3EPI0q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 04:26:46 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03458-09 for <netdev@vger.kernel.org>;
 Thu, 16 May 2013 09:26:43 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <OF80FDF86D.7A293781-ON85257B6C.0061CCF7-85257B6C.0063F69C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > From: Stephen Hemminger <stephen@networkplumber.org>
> >
> > I want all new users to get the IANA port without asking.
> > Old users with existing nets have to force the port to the one they
> > were using.
> 
> That'd be great -- what we're getting is all new users are getting
> a listen port of 8472 and a send port of 4789. So new users who aren't
> aware of why will simply see that two *new* installations don't talk
> to each other (and never will, using default ports, because the kernel
> and ip will need to be compatible with their incompatible selves).

Could the kernel listen on both port numbers?
Then the default 'send' port could be changed while maintaining
functionality for existing systems.

At some later time the listener on 8372 could be removed.

	David
