From: Paulo Marques <pmarques@grupopie.com>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Mon, 02 May 2005 15:16:11 +0100
Message-ID: <4276362B.1010004@grupopie.com>
References: <E1DRFqC-00028H-Qi@tigger>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261260AbVEBOQU@vger.kernel.org>
To: Mark Broadbent <markb@wetlettuce.com>
In-Reply-To: <E1DRFqC-00028H-Qi@tigger>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Broadbent wrote:
> The interrupt handling code in the tulip network driver appears to use a non 
> IRQ safe spinlock in an interrupt context.  The following patch should correct 
> this.

Huh? Can a network interrupt handler be interrupted by the same interrupt?

AFAIK, the spin_lock_irqsave is to disable interruptions so that an
interrupt can not happen in the critical section, so that the interrupt
handler can not make modifications to shared data. Am I wrong?

-- 
Paulo Marques - www.grupopie.com

All that is necessary for the triumph of evil is that good men do nothing.
Edmund Burke (1729 - 1797)
