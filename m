From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 01/22] bnx2x: Support probing and removing
 of VF device
Date: Mon, 10 Dec 2012 10:50:59 -0800
Message-ID: <1355165459.26815.27.camel@joe-AO722>
References: <1355154406-10855-1-git-send-email-ariele@broadcom.com>
	 <1355154406-10855-2-git-send-email-ariele@broadcom.com>
	 <20121210.133519.2048543022289027034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59208 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750803Ab2LJSu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 13:50:58 -0500
In-Reply-To: <20121210.133519.2048543022289027034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 13:35 -0500, David Miller wrote:
> From: "Ariel Elior" <ariele@broadcom.com>
> Date: Mon, 10 Dec 2012 17:46:25 +0200
[]
> > @@ -12023,85 +12057,115 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
> >        * If MSI-X is not supported - return number of SBs needed to support
> >        * one fast path queue: one FP queue + SB for CNIC
> >        */
> > -     if (!pos)
> > +     if (!pos) {
> > +             pr_info("no msix capability found");
[]
> Use dev_info(), netdev_info(), or similar, rather than plain
> pr_info().

Also, please add terminating newlines to avoid
dmesg message interleaving.
