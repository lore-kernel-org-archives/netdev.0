From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 1/5] I/OAT DMA support and TCP acceleration
Date: Wed, 21 Dec 2005 10:28:05 +0300
Message-ID: <20051221072805.GA15850@2ka.mipt.ru>
References: <1135142254.13781.18.camel@cleech-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Grover, Andrew" <andrew.grover@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932306AbVLUH2S@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <1135142254.13781.18.camel@cleech-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2005 at 09:17:34PM -0800, Chris Leech (christopher.leech@intel.com) wrote:
> DMA memcpy subsystem
> Provides an API for offloading memory copies to DMA devices.
> Along with client registration and DMA channel allocation, the main APIs are:
> 	dma_async_memcpy_buf_to_buf()
> 	dma_async_memcpy_buf_to_pg()
> 	dma_async_memcpy_pg_to_pg()
> 	dma_async_memcpy_complete()

Is here at least some locking?
All dma chain/engine list manipulations seem very suspicious.


-- 
	Evgeniy Polyakov
