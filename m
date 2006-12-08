From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH] myri10ge: pci msi and express state save/restore
Date: Fri, 08 Dec 2006 18:28:07 +0100
Message-ID: <4579A0A7.6090304@myri.com>
References: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:44653 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1426045AbWLHR32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 12:29:28 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks ok to me, except that you should also remove devctl and
msi_flags from myri10ge_priv since these fields were only used in the
functions that are dropped by this patch.

However, I won't be able to test the patch on real hardware within the
next days...

Thanks a lot!
Brice




Stephen Hemminger wrote:
> The PCI MSI and express state are already saved and restored by the
> current versions of pci_save_state/pci_restore_state.
> Therefore it should no longer be necessary for the driver to do it.
> This patch has not been tested on the hardware.
>
> On suspend, handle pci_set_power_state errors, and on resume
> handle failures in pci_resume_state().
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> ---
>  drivers/net/myri10ge/myri10ge.c |   48 +++++++++-------------------------------
>  1 file changed, 11 insertions(+), 37 deletions(-)
>   

