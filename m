From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2/2] net: add driver for Netronome NFP4000/NFP6000
 NIC VFs
Date: Fri, 30 Oct 2015 19:27:01 +0900 (KST)
Message-ID: <20151030.192701.377276134095637949.davem@davemloft.net>
References: <1445969758-12779-1-git-send-email-jakub.kicinski@netronome.com>
	<1445969758-12779-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030730AbbJ3K1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 06:27:05 -0400
In-Reply-To: <1445969758-12779-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 27 Oct 2015 18:15:58 +0000

> + * @msix_table:         Pointer to mapped MSI-X table

The PCI layer already has the MSI-X table mapped, and provides
common routines for masking and unmasking MSI-X interrupts.

Please use that instead of reimplementing those facilities.
