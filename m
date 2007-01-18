From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 1/5] s2io: updates for s2io driver.
Date: Thu, 18 Jan 2007 12:01:31 -0500
Message-ID: <45AFA7EB.8060601@garzik.org>
References: <Pine.GSO.4.10.10701110230560.1618-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	sivakumar.subramani@neterion.com, alicia.pena@neterion.com,
	sreenivasa.honnur@netrion.com, ramkrishna.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44472 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbXARRBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 12:01:38 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701110230560.1618-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> Hello, 
> 
> List of changes in this patch:
> 
> 	This patch adds two load parameters napi and ufo. Previously NAPI was
> compilation option with these changes wan enable disable NAPI using load
> parameter. Also we are introducing ufo load parameter to enable/disable
> ufo feature
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


