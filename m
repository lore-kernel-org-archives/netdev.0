From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage release.
Date: Mon, 13 Oct 2008 18:14:49 +0400
Message-ID: <20081013141449.GA30768@2ka.mipt.ru>
References: <20081006160034.GA611@2ka.mipt.ru> <20081012192419.fd8394c9.akpm@linux-foundation.org> <20081013133850.GA13565@2ka.mipt.ru> <84144f020810130644w7f89f3d9m3c3d3e63d3034534@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <84144f020810130644w7f89f3d9m3c3d3e63d3034534@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pekka.

On Mon, Oct 13, 2008 at 04:44:28PM +0300, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> > What's the difference? In saving one space and replacing another with
> > comma? I do not particulary care, but would like to know why it is
> > needed :)
> 
> kcalloc() will check for multiplication overflow which is nice
> especially if size is passed from user-space (not sure if that applies
> here).

I think that 32-bit overflow check during multiplication in allocation
code is the last thing to worry about :)
If this parameters are not checked before, we are screwd already...

P.S. DST does not check one of them, oops.

-- 
	Evgeniy Polyakov
