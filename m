From: David Rientjes <rientjes@google.com>
Subject: RE: Latest 3.6.6 are not compiling due tg3 network driver,
 hwmon_device_unregister
Date: Wed, 14 Nov 2012 23:51:14 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1211142349310.4410@chino.kir.corp.google.com>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb> <50A4606D.4020402@broadcom.com> <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com> <DAAFBCC105999F468732FA900576CB4510069F69@IRVEXCHMB08.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nithin Sujir <nsujir@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DAAFBCC105999F468732FA900576CB4510069F69@IRVEXCHMB08.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2012, Nithin Sujir wrote:

> > Would you mind submitting this for stable by following the procedure
> > described in Documentation/stable_kernel_rules.txt?
> 
> 
> Seems to have been taken into stable already. 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commitdiff;h=aecdc33e111b2c447b622e287c6003726daa1426
> 

You're looking at the wrong shortlog (that's 3.7-rc4, not a stable tree), 
you'll want to backport this on top of 3.6.6 and send it to 
stable@vger.kernel.org following the procedure in 
Documentation/stable_kernel_rules.txt.
