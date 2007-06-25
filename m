From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer
 dereferencing, take 2
Date: Mon, 25 Jun 2007 16:30:15 -0700
Message-ID: <20070625163015.175d15c0.akpm@linux-foundation.org>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
	<a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
	<20070625153450.c5f535ca.akpm@linux-foundation.org>
	<46804C3D.3080205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pradeep singh <pradeep.rautela@gmail.com>, trivial@kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50280 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751249AbXFYXae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 19:30:34 -0400
In-Reply-To: <46804C3D.3080205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jun 2007 19:14:05 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Andrew Morton wrote:
> > The chelsio driver is assuming that pci_device_id.driver_data has been
> > initialised to the board index, but I am unable to locate anywhere where
> > that initialisation actually happens.
> 
> It's hidden inside the CH_DEVICE() initializer-helper macro.
> 

oic.

Does this driver still have a maintainer, or is it now a "community"
driver (giggle) ?
