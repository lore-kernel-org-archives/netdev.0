From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] net: sched: One function call less in em_meta_change()
 after error detection
Date: Sat, 31 Jan 2015 22:48:01 +0100
Message-ID: <54CD4D91.9080801@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <54CD042E.6030606@users.sourceforge.net> <54CD115C.8070801@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:55317 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbbAaVsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2015 16:48:11 -0500
In-Reply-To: <54CD115C.8070801@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +exit:
>>  	return err;
>>  }
> 
> Why do you use that exit label if it does nothing more than returning
> the error value? Also if nla_parse fails you dont use it but return the
> error directly. While using a label which is used only to return an
> error may be a matter of taste, its at least inconsistent to do both in
> a function, use such a label in one case and return immediately in
> another, isnt it?

I find that all these cases correspond to the current Linux coding
style documentation, doesn't it?

Regards,
Markus
