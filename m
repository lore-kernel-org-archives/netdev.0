From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.27.y] stable request for vlan fix
Date: Mon, 2 Feb 2009 19:43:51 -0800
Message-ID: <20090203034351.GA1867@kroah.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10A1C341494@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "stable@kernel.org" <stable@kernel.org>,
	"ccaputo@alt.net" <ccaputo@alt.net>, Karsten Keil <kkeil@suse.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:40179 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751358AbZBCDwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 22:52:05 -0500
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1C341494@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 04:53:32PM -0800, Brandeburg, Jesse wrote:
> I had a customer report that e1000/e1000e was hitting a vlan bug when 
> compiled without NAPI support.  Turns out it had been solved already 
> in a newer kernel.  Please consider for stable.
> 
> this commit was pushed in the 2.6.28-rc4 timeframe
> 
> git-cherry-pick 9b22ea560957de1484e6b3e8538f7eef202e3596

Thanks, I'll queue that one up tomorrow.

greg k-h
