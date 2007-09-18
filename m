From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 17:04:32 -0700
Message-ID: <20070917170432.fe4e973c.akpm@linux-foundation.org>
References: <20070916.202258.03371690.davem@davemloft.net>
	<20070917.141826.70218261.davem@davemloft.net>
	<BAE9DCEF64577A439B3A37F36F9B691C030EF13C@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linville@tuxdriver.com>, <jgarzik@pobox.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34522 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758531AbXIRAFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 20:05:21 -0400
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C030EF13C@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007 16:57:03 -0700
"Nelson, Shannon" <shannon.nelson@intel.com> wrote:

> >From: netdev-owner@vger.kernel.org 
> >[mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
> >Sent: Monday, September 17, 2007 2:18 PM
> >To: netdev@vger.kernel.org
> >Cc: akpm@linux-foundation.org; linville@tuxdriver.com; 
> >jgarzik@pobox.com
> >Subject: Re: net-2.6.24 plans
> [...]
> >
> >Andrew, I removed the troublesome IOAT patch.  The only conflicts
> >and fixes you should need at this point are:
> >
> [...]
> 
> Which IOAT patch are you referring to?
> 

A dopey one-liner which removes unused variable `u16 chanctrl'.  It caused
rather a mess due to all the dma changes we have queued.  It's under control.
