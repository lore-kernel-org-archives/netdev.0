From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: [PATCH] 8139cp: Catch all interrupts
Date: Mon, 31 Oct 2005 19:14:44 +0100
Message-ID: <43665F14.9040700@drzeus.cx>
References: <431761BA.5080007@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Felipe Damasio <felipewd@terra.com.br>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932298AbVJaSOu@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <431761BA.5080007@drzeus.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pierre Ossman wrote:
> Register interrupt handler when net device is registered. Avoids missing
> interrupts if the interrupt mask gets out of sync.
> 
> Signed-off-by: Pierre Ossman <drzeus@drzeus.cx>
> 
> ---
> 
> The reason this patch is needed for me is that the resume function is
> broken. It enables interrupts unconditionally, but the interrupt handler
> is only registered when the device is up.
> 
> I don't have enough knowledge about the driver to fix the resume
> function so this patch will instead make sure that the interrupt handler
> is registered at all times (which can be a nice safeguard even when the
> resume function gets fixed).
> 

Any comments on this?
