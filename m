From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 28 Jun 2006 18:32:00 +0200
Message-ID: <200606281832.01108.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606281634.24160.mb@bu3sch.de> <44A2A872.3050905@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:7391
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751350AbWF1QcK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 12:32:10 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A2A872.3050905@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 June 2006 18:04, Larry Finger wrote:
> Michael Buesch wrote:
> > 
> > It appears to be an older card. There are quite some
> > special codepaths for this, I think.
> 
> Yes, I bought this card before the G specifications were finalized.

Oh, very interresting. I did not know that these old cards
were pre-standard.

> For the past 12 hours, I have been printing the delay time for the cases where it took more  
> than 2 passes through the loop. There have been single instances of 3 and 4 usec; otherwise the 
> delay is much longer, with the largest delay at 750 usec. The long delays are always found during 
> scanning, associating, and authenticating. I use WPA with wpa_supplicant.

Oh, well. Forget it all.
I remembered the code wrong.
At the moment I looked at the code and it has the opposite semantics.
It loops to wait for the READY bit to appear.

Well, I would say your old device simply takes this long
to disable and there is no bug.

Oh, well...

> One other little problem. If I do an ifdown/ifup sequence without unloading the bcm43xx module, I 
> get a failure of the assert(bcm->mac_suspended >= 0) at the beginning of bcm43xx_mac_suspend.

Unrelated known bug.
I will do a patch, soon.

-- 
Greetings Michael.
