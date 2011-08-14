From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] usbnet/cdc_ncm: Don't use stack variables for DMA
Date: Sat, 13 Aug 2011 18:01:23 -0700 (PDT)
Message-ID: <20110813.180123.46722618651238324.davem@davemloft.net>
References: <20110808123406.GA2526@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, alexey.orishko@stericsson.com, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jwboyer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110808123406.GA2526@zod.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@redhat.com>
Date: Mon, 8 Aug 2011 08:34:07 -0400

> The cdc_ncm driver still has a few places where stack variables are
> passed to the cdc_ncm_do_request function.  This triggers a stack trace in
> lib/dma-debug.c if the CONFIG_DEBUG_DMA_API option is set.
> 
> Adjust these calls to pass parameters that have been allocated with
> kzalloc.
> 
> Signed-off-by: Josh Boyer <jwboyer@redhat.com>

Applied.
