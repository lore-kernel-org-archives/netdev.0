From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2]:  powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 12:30:29 -0400
Message-ID: <44E34825.2020105@garzik.org>
References: <20060811170337.GH10638@austin.ibm.com> <20060816161856.GD20551@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932098AbWHPQax@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060816161856.GD20551@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Please apply and forward upstream. This patch requires the previous
> sequence of 4 spidernet patches to be applied.
> 
> --linas
> 
> 
> The recent set of low-waterark patches for the spider result in a
> significant amount of computing being done in an interrupt context.
> This patch moves this to a "bottom half" aka work queue, so that
> the code runs in a normal kernel context. Curiously, this seems to 
> result in a performance boost of about 5% for large packets.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: Utz Bacher <utz.bacher@de.ibm.com>
> Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>

Let's not reinvented NAPI, shall we...

	Jeff
