From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 12:34:44 -0800
Message-ID: <1171398884.18944.35.camel@rh4>
References: <1171397612.18944.25.camel@rh4>
 <20070213194534.GB16991@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1567 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbXBMTvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:51:20 -0500
In-Reply-To: <20070213194534.GB16991@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-13 at 14:45 -0500, Jeff Garzik wrote:

> 
> I'm curious if, after this patch is applied, all the pci_save_state()
> calls are truly necessary?
> 

The others are necessary to save/restore the memory enable bit in the
PCI command register.  This bit gets reset after chip reset.

