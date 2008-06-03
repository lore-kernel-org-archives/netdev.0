From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: howto use ioremap_wc?
Date: Mon, 2 Jun 2008 19:18:32 -0700
Message-ID: <20080602191832.0858eff9@infradead.org>
References: <4841143E.5080003@myri.com>
	<20080531185424.1cd18220@infradead.org>
	<48441F73.5040005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"venkatesh.pallipadi@intel.com" <venkatesh.pallipadi@intel.com>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50683 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbYFCCSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 22:18:36 -0400
In-Reply-To: <48441F73.5040005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Jun 2008 18:27:31 +0200
Brice Goglin <brice@myri.com> wrote:


> 
> Agreed, that would be nice!
> 
> >From what we discussed here after your reply, our plan is now to just
> replace
>     ioremap+mtrr_add

which doesn't work as ioremap() may/will force uncached ;)


> with
>     ioremap_wc+mtrr_add
> 
> If mtrr_add() is moved into ioremap_wc(), we'll remove it from
> myri10ge. For now, when PAT is enabled, we may have PAT + MTRR both
> doing WC, but I don't think it can break anything, right?

Both having WC is nicely consistent and the right thing happens...

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
