From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [RFC,1/8] soc/fman: Add FMan MURAM support
Date: Thu, 12 Mar 2015 10:56:55 -0500
Message-ID: <32CF85E2-A8AA-454D-A46F-0E778DAF97ED@kernel.crashing.org>
References: <1426050469-12507-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com
To: "Igal.Liberman" <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426050469-12507-1-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 11, 2015, at 12:07 AM, Igal.Liberman <igal.liberman@freescale.com> wrote:

> From: Igal Liberman <Igal.Liberman@freescale.com>
> 
> Add Frame Manager Multi-User RAM support.
> 
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
> drivers/soc/fsl/fman/Kconfig            |    1 +
> drivers/soc/fsl/fman/Makefile           |    5 +-
> drivers/soc/fsl/fman/fm_muram.c         |  174 +++++++++++++++++++++++++++++++
> drivers/soc/fsl/fman/inc/fm_muram_ext.h |   98 +++++++++++++++++
> 4 files changed, 276 insertions(+), 2 deletions(-)
> create mode 100644 drivers/soc/fsl/fman/fm_muram.c
> create mode 100644 drivers/soc/fsl/fman/inc/fm_muram_ext.h
> 

use lib/genalloc instead of rheap

- k