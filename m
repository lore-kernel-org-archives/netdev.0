From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: bug in passing file descriptors
Date: Tue, 8 Oct 2013 09:43:52 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B737A@saturn3.aculab.com>
References: <5253061A.7060701@nec-labs.com> <20131007.151233.2237348893254566536.davem@davemloft.net> <525308C4.1030007@nec-labs.com> <20131007.154226.533738557474978526.davem@davemloft.net> <5253199B.3000109@nec-labs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <luto@amacapital.net>, <netdev@vger.kernel.org>,
	<mtk.manpages@gmail.com>, <ebiederm@xmission.com>
To: "Steve Rago" <sar@nec-labs.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52779 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754398Ab3JHIrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 04:47:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28720-04 for <netdev@vger.kernel.org>;
 Tue,  8 Oct 2013 09:47:02 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5253199B.3000109@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > There is no compatability issue.
> >
> > 32-bit tasks will always see the 4-byte align/length.
> > 64-bit tasks will always see the 8-byte align/length.
> >
> 
> Really?  So when I compile my application on a 32-bit Linux box and then try to run it on a 64-bit
> Linux box, you're not
> going to overrun my buffer when CMSG_SPACE led me to allocate an insufficient amount of memory needed
> to account for
> padding on the 64-bit platform?

Worth checking what happens if you try to send an fd between a 32 bit
application and a 64bit one.
Also is the fd actually closed if the receiving applications buffer
isn't big enough.

	David
