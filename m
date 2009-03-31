From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH 13/17] x86: allow the irq->vector translation to be
 determined outside of ioapic
Date: Tue, 31 Mar 2009 20:16:25 +0100
Message-ID: <20090331201625.60f1ea81@the-village.bc.nu>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
	<20090331184355.28333.72382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090331184355.28333.72382.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Mar 2009 14:43:55 -0400
Gregory Haskins <ghaskins@novell.com> wrote:

> The ioapic code currently privately manages the mapping between irq
> and vector.  This results in some layering violations as the support
> for certain MSI operations need this info.  As a result, the MSI
> code itself was moved to the ioapic module.  This is not really
> optimal.

This appears to have been muddled in with the vnet patches ?
