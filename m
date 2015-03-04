From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: Delete unnecessary checks before the function call "release_firmware"
Date: Wed, 4 Mar 2015 14:06:21 +0200
Message-ID: <87twy16k76.fsf@kamboji.qca.qualcomm.com>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54D26614.2080708@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>,
	<kernel-janitors@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D26614.2080708@users.sourceforge.net> (SF Markus Elfring's
	message of "Wed, 04 Feb 2015 19:33:56 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring@users.sourceforge.net> writes:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 19:30:23 +0100
>
> The release_firmware() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Thanks, applied to ath.git.

-- 
Kalle Valo
