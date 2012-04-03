From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] sky2: fix missing register reset on error path in
 sky2_test_msi()
Date: Tue, 3 Apr 2012 22:09:32 +0200
Message-ID: <20120403200932.GA2383@Neptun>
References: <20120330173616.GC2703@Neptun>
 <20120403115547.799fcc1f@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120403115547.799fcc1f@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 03, 2012 at 11:55:47AM -0700, Stephen Hemminger wrote:
> Ok, but this is a non-serious error case. If request_irq() fails here,
> the driver is going to fail to load and on the failure path of
> sky2_probe will reset the chip on the way out.
> 
Youre right, this is more a cosmetic change than a fix for a real bug. 
