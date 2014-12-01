From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: net-PA Semi: Deletion of unnecessary checks before the function
 call "pci_dev_put"
Date: Mon, 01 Dec 2014 02:34:37 +0100
Message-ID: <547BC5AD.6090500@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547A09B1.9090102@users.sourceforge.net> <547B579F.10709@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <547B579F.10709-Mmb7MZpHnFY@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I know there has been some criticism about those kind of "code
> improvements" already but i would like to point out just one more thing:
> 
> Some of those NULL pointer checks on input parameters may have been
> added subsequently to functions. So there may be older kernel versions
> out there in which those checks dont exists in some cases. If some of
> the now "cleaned up" code is backported to such a kernel chances are
> good that those missing checks are overseen. And then neither caller nor
> callee is doing the NULL pointer check.

I guess that the Coccinelle software can also help you in this use case.
How do you think about to shield against "unwanted" or unexpected collateral
evolutions with additional inline functions?

I assume that a few backporters can tell you more about their corresponding
software development experiences.
http://www.do-not-panic.com/2014/04/automatic-linux-kernel-backporting-with-coccinelle.html

Regards,
Markus
