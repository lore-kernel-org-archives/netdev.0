From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 10 Nov 2015 20:13:03 +0100
Message-ID: <564241BF.4020700@free.fr>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447172063-27234-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/2015 17:14, Mans Rullgard wrote:

> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
> It is an almost complete rewrite of a driver originally found in
> a Sigma Designs 2.6.22 tree.
> 
> Signed-off-by: Mans Rullgard <mans@mansr.com>
> ---
> Changes:
> - Refactored mdio access functions
> - Refactored register access helpers
> - Improved error handling in rx buffer allocation
> - Optimised some fifo parameters
> - Overhauled tx dma. Multiple packets are now chained in a single dma
>   operation if xmit_more is set, improving performance.
> - Improved rx irq handling. It's not possible to disable interrupts
>   entirely for napi poll, but they can be slowed down a little.
> - Use readx_poll_timeout in various places
> - Improved error detection
> - Improved statistics
> - Report hardware statistics counters through ethtool
> - Improved tangox-specific setup
> - Support for flow control using pause frames
> - Explanatory comments added
> - Various minor stylistic changes
> ---
>  drivers/net/ethernet/Kconfig         |    1 +
>  drivers/net/ethernet/Makefile        |    1 +
>  drivers/net/ethernet/aurora/Kconfig  |   20 +
>  drivers/net/ethernet/aurora/Makefile |    1 +
>  drivers/net/ethernet/aurora/nb8800.c | 1530 ++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/aurora/nb8800.h |  314 +++++++
>  6 files changed, 1867 insertions(+)

The code has grown much since the previous patch, despite some
refactoring. Is this mostly due to ethtool_ops support?

 drivers/net/ethernet/aurora/nb8800.c | 1146 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/aurora/nb8800.h |  230 +++++++

Regards.
