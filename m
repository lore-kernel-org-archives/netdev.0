From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: net-PA Semi: Deletion of unnecessary checks before the function
 call "pci_dev_put"
Date: Sun, 30 Nov 2014 22:36:34 +0100
Message-ID: <547B8DE2.9030301@gmx.de>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547A09B1.9090102@users.sourceforge.net> <547B579F.10709@gmx.de> <alpine.DEB.2.10.1411301846560.2522@hadrien> <547B6F9A.8030806@gmx.de> <547B80B7.5030707@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:60374 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbaK3Vgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2014 16:36:35 -0500
In-Reply-To: <547B80B7.5030707@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.11.2014 21:40, SF Markus Elfring wrote:
>> Maybe this topic should be clarified somewhere (e.g. in "CodingStyle")?
>> On the other hand i always found it obvious that its the callers
>> responsibility to only pass sane parameters to the called functions...
> 
> Can you imagine that any more source code places which would benefit from
> check adjustments because of defensive programming?
> 

I am not sure if i understand your question correctly. But i would not
call sanity checks for function parameters "defensive programming". I
would rather call it not being totally careless. So to me the question
if those checks should be done or not is different from the question
whether there are code parts that would benefit from an adjustment to
defensive programming.

Regards,
Lino
