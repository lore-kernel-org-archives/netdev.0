From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [ANNOUNCE] Open-FCoE - Fibre Channel over Ethernet Project
Date: Wed, 28 Nov 2007 07:44:26 +0000
Message-ID: <20071128074426.GA30468@infradead.org>
References: <10A7D0016239E24092DEF05CCC582E43028A636B@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-scsi@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	devel@open-fcoe.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Rob Love <robert.w.love@linux.intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Zou, Yi" <yi.zou@intel.com>, "Dev, Vasu" <vasu.dev@intel.com>,
	james.bottomley@hansenpartnership.com, davem@davemloft.net,
	jeff@garzik.org, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Van De Ven, Arjan" <arjan.van.de.ven@intel.com>,
	Mike Christie <michaelc@cs.wisc.edu>
To: "Love, Robert W" <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <10A7D0016239E24092DEF05CCC582E43028A636B@fmsmsx411.amr.corp.intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just did a very quick glance over the tree.  Some extremly highlevel
comments to start with before actually starting the source review:


 - why do you need your own libcrc?  lib/crc32.c has a crc32_le
 - libsa should go.  Much of it is just wrappers of kernel functions
   that should be used directly.  Other like that hash, even or state
   helpers might either be opencoded in the caller or made completely
   generic in lib/.  Probably the former but we'll have to see.
