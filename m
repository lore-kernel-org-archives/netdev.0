From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2010-06-16 v2
Date: Thu, 17 Jun 2010 07:48:56 -0400
Message-ID: <20100617114856.GA4009@tuxdriver.com>
References: <20100616182847.GB3138@tuxdriver.com>
 <20100616.115008.226776050.davem@davemloft.net>
 <20100616201300.GD3138@tuxdriver.com>
 <AANLkTinbJD3bWYSJ3aZZIDi1cUE_BOvLI-iUQtPF50Hm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55257 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab0FQNPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 09:15:10 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinbJD3bWYSJ3aZZIDi1cUE_BOvLI-iUQtPF50Hm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 17, 2010 at 12:57:22AM +0200, Sedat Dilek wrote:
> Quick feedback:
> 
> I have applied latest wireless-2.6 master GIT against 2.6.35-rc3:
> 
> wireless-2.6/0001-iwlwifi-serialize-station-management-actions.patch
> wireless-2.6/0002-iwlagn-verify-flow-id-in-compressed-BA-packet.patch
> wireless-2.6/0003-libertas_tf-Fix-warning-in-lbtf_rx-for-stats-struct.patch
> wireless-2.6/0004-p54pci-add-Symbol-AP-300-minipci-adapters-pciid.patch
> wireless-2.6/0005-wireless-orphan-ipw2x00-drivers.patch
> wireless-2.6/0006-iwlwifi-cancel-scan-watchdog-in-iwl_bg_abort_scan.patch
> wireless-2.6/0007-hostap-Protect-against-initialization-interrupt.patch
> wireless-2.6/0008-mac80211-fix-warn-enum-may-be-used-uninitialized.patch
> 
> Unfortunately, I get here an issue with iwl3945 (full dmesg attached):
> 
> [ dmesg ]
> [   26.423844]  [<f924b2f1>] ? iwl_tx_cmd_complete+0x51/0x1c5 [iwlcore]
> ...
> [   26.432470] iwl3945 0000:10:00.0: Can't stop Rx DMA.
> 
> Hope this helps.

I think a full bug report at bugzilla.kernel.org would help more. :-)

In that report, please include the full output of dmesg and a
description of what you were doing when message above appeared.

Thanks,

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
