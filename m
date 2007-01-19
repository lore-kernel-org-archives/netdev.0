From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 2.6.20 1/5] s2io: updates for s2io driver.
Date: Fri, 19 Jan 2007 02:55:27 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77011EBF00@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Alicia Pena" <Alicia.Pena@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [72.1.205.142] ([72.1.205.142]:45246 "EHLO owa.neterion.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932795AbXASR2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 12:28:05 -0500
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Thanks for the comments and references.

As per you suggestion, we have resubmitted the patches with required
change.

Thanks,
~Siva 

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Thursday, January 18, 2007 10:32 PM
To: Ananda Raju
Cc: netdev@vger.kernel.org; Leonid Grossman; Sivakumar Subramani; Alicia
Pena; sreenivasa.honnur@netrion.com; Ramkrishna Vepa
Subject: Re: [PATCH 2.6.20 1/5] s2io: updates for s2io driver.

Ananda Raju wrote:
> Hello,
> 
> List of changes in this patch:
> 
> 	This patch adds two load parameters napi and ufo. Previously
NAPI was 
> compilation option with these changes wan enable disable NAPI using 
> load parameter. Also we are introducing ufo load parameter to 
> enable/disable ufo feature
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

OK, you're getting closer :)

Problems that need correcting:

1) Your email subject line is a one-line summary of the patch.  "s2io: 
updates for s2io driver" is useless, because it tells us nothing about
the patch itself.  When applied in a series,

	git log master..upstream-fixes | git shortlog

will produce

	Ananda Raju (5):
	s2io: updates for s2io driver
	s2io: updates for s2io driver
	s2io: updates for s2io driver
	s2io: updates for s2io driver
	s2io: updates for s2io driver

which clearly makes it impossible to distinguish between changesets. 
Please re-read Rule #1 of http://linux.yyz.us/patch-format.html

Also, re-read Rule #2.  Everything in your email body before the "---" 
terminator is copied DIRECTLY into the kernel changelog.  As such,
comments like "Hello," and "List of changes in this patch:" must be
hand-edited out of your email, before applying the patch.

Please fix these problems and resubmit.

	Jeff


