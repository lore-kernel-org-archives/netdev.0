From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/1] net-PA Semi: Deletion of unnecessary checks before
 the function call "pci_dev_put"
Date: Sun, 30 Nov 2014 20:27:22 +0100
Message-ID: <547B6F9A.8030806@gmx.de>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547A09B1.9090102@users.sourceforge.net> <547B579F.10709@gmx.de> <alpine.DEB.2.10.1411301846560.2522@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1411301846560.2522@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.11.2014 18:47, Julia Lawall wrote:

> 
> I have heard of at least one case where the problem you are raising
> happened in practice...
> 
> julia

If one case is known then there are probably a lot more that have not
been discovered yet.
Maybe this topic should be clarified somewhere (e.g. in "CodingStyle")?
On the other hand i always found it obvious that its the callers
responsibility to only pass sane parameters to the called functions...

Regards,
Lino
