From: Andreas Klauer <Andreas.Klauer@metamorpher.de>
Subject: Re: 2.6.34 + IPv6: Oops?
Date: Mon, 21 Jun 2010 17:30:18 +0200
Message-ID: <20100621153018.GA2433@EIS>
References: <20100619175352.GA8482@EIS>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay04.ispgateway.de ([80.67.31.42]:39196 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756Ab0FUPaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 11:30:21 -0400
Received: from [93.211.32.144] (helo=localhost)
	by smtprelay04.ispgateway.de with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.68)
	(envelope-from <Andreas.Klauer@metamorpher.de>)
	id 1OQix0-0005oU-F6
	for netdev@vger.kernel.org; Mon, 21 Jun 2010 17:30:18 +0200
Content-Disposition: inline
In-Reply-To: <20100619175352.GA8482@EIS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

no one replied so far - am I reporting this to the wrong place?
Please advise.

I've done some more testing; I can reproduce the issue now on different 
hardware (my desktop at home), with a clean environment (freshly boot- 
strapped Debian Lenny). Which should make things more interesting. 

The issue seems to be compiler related. It occurs if the kernel is 
compiled with Debian Lenny "gcc (Debian 4.3.2-1.1) 4.3.2". It does 
not occur (or at least I can't reproduce it) if the kernel was 
compiled with Gentoo "gcc (Gentoo 4.4.4 p1.0) 4.4.4".

Screenshot:
http://www.metamorpher.de/kernel/panic2.jpg

Steps to reproduce:
http://www.metamorpher.de/kernel/steps-to-reproduce.txt

kernel config and lspci also available here:
http://www.metamorpher.de/kernel/

Regards
Andreas Klauer
