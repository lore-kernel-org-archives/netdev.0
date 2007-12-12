From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking
 GSOed skbs when SACKed one-by-one
Date: Wed, 12 Dec 2007 15:38:13 -0800 (PST)
Message-ID: <20071212.153813.145077378.davem@davemloft.net>
References: <aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
	<20071212.071136.26499607.davem@davemloft.net>
	<aa7d2c6d0712121535y31bea3a6v14e270293c272e6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	quetchen@caltech.edu, d.veitch@ee.unimelb.edu.au
To: lachlan.andrew@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42279
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751047AbXLLXiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 18:38:14 -0500
In-Reply-To: <aa7d2c6d0712121535y31bea3a6v14e270293c272e6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Date: Wed, 12 Dec 2007 15:35:49 -0800

> I thought that a TSC read was fairly cheap.

The TSC is cheap, but on the vast majority of systems it
isn't usable as a stable time source, and we have to read
the ACPI timer instead.
