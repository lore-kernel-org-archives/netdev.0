From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [PATCH] NET/r8169: Rework suspend and resume
Date: Sun, 5 Apr 2009 22:33:18 +0200
Message-ID: <20090405223318.5a494e4e@neptune.home>
References: <200904052040.04752.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758413AbZDEUdg@vger.kernel.org>
In-Reply-To: <200904052040.04752.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 05 April 2009 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The recent changes of the PCI PM core allow us to simplify the
> suspend and resume handling in a number of device drivers, since they
> don't need to carry out the general PCI PM operations, such as
> changing the power state of the device, during suspend and resume any
> more.
> 
> Simplify the suspend and resume callbacks of r8169 using the
> observation that the PCI PM core can take care of some operations
> carried out by the driver.
> 
> Additionally, make the shutdown callback of r8169 only put the device
> into a low power state if the system is going to be powered off
> (kexec is known to have problems with network adapters that are put
> into low power states on shutdown).
> 
> This patch has been tested on MSI Wind U100.

Tested against 2.6.29.1 on my Commell LE-365 and suspend (S3) + WoL
still works as expected.

02:08.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
                     RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)

Bruno
