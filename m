From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/1] smsc: Enabling SMSC LAN911 driver for ARM64 as well.
Date: Mon, 11 Jan 2016 10:16:38 -0500
Message-ID: <5693C756.8010108@windriver.com>
References: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <pankaj.m@samsung.com>
To: Manjeet Pawar <manjeet.p@samsung.com>, <davem@davemloft.net>,
	<schmitzmic@gmail.com>, <geert@linux-m68k.org>, <nico@fluxnic.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<akhilesh.k@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-01-11 04:02 AM, Manjeet Pawar wrote:
> This patch enable network driver support for ARM64

Your commit log only repeats what is obvious from the one line
change itself.  It might be nice to indicate what platform it
was validated on, what tests were run and what features of the
driver were exercised (multicast, netpoll, ...)

Imagine if I sent you a similar patch where I added MIPS and
said nothing more than "enable network driver support for MIPS"
and Cc'd you expecting you to comment on whether it was OK.

Thanks,
Paul.
