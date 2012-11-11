From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 17:47:32 -0500
Message-ID: <201211112247.qABMlWiQ021630@thirdoffive.cmf.nrl.navy.mil>
References: <20121111110437.GA25894@shrek.podlesie.net>
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20121111110437.GA25894@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <20121111110437.GA25894@shrek.podlesie.net>,Krzysztof Mazur writes:
>Any race with testing vcc flags is probably not really important
>because:
>	- vcc_release_async() does not take any lock so this check
>	  will be always racy so we are probably allowed to send
>	  new frames until vcc is really closed,

this locking/synchronization is handled in the atm device drivers.
the send and close routines are responsbile for synchronization (yes, i
believe that leads to duplicated code but that is the way it currently is)
