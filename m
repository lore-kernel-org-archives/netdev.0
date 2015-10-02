From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v3 1/8] devres: add devm_alloc_percpu()
Date: Thu, 1 Oct 2015 20:00:41 -0500
Message-ID: <20151002010041.GA4245@home.buserror.net>
References: <1443106819-5549-1-git-send-email-madalin.bucur@freescale.com>
 <1443106819-5549-2-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<igal.liberman@freescale.com>, <roy.pledge@freescale.com>,
	<ppc@mindchasers.com>, <joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <f.fainelli@gmail.com>,
	<stsp@list.ru>
To: Madalin Bucur <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443106819-5549-2-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 06:00:12PM +0300, Madalin Bucur wrote:
> Introduce managed counterparts for alloc_percpu() and free_percpu().
> Add devm_alloc_percpu() and devm_free_percpu() into the managed
> interfaces list.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> Tested-by: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
> ---
>  Documentation/driver-model/devres.txt |  4 +++
>  drivers/base/devres.c                 | 64 +++++++++++++++++++++++++++++++++++
>  include/linux/device.h                | 19 +++++++++++
>  3 files changed, 87 insertions(+)

Greg KH needs to be CCed on any drivers/base changes.

-Scott
