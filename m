From: Florian Mickler <florian@mickler.org>
Subject: Re: [PATCH 6/7] e1000e: cleanup: swap arguments to avoid checkpatch
 errors
Date: Thu, 9 Dec 2010 11:34:16 +0100
Message-ID: <20101209113416.66baf7ac@schatten.dmk.lab>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
	<1291862457-16671-7-git-send-email-asbjorn@asbjorn.biz>
	<1291865548.19763.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291865548.19763.1.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Dec 2010 03:32:28 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2010-12-09 at 02:40 +0000, Asbjoern Sloth Toennesen wrote:
> > Swap argument order in order to avoid checkpatch treating it as an
> > unary operation, instead of an binary one, and obtain consistency
> > with the 3 other similar assignments in netdev.c (tdlen & rdlen).
> > 
> > This patch fixes 3 checkpatch errors.
> 
> You have got to be kidding.  If the checkpatch warning offends you, fix
> the bug in checkpatch instead of changing perfectly good code.
> 
> Ben.

That bug is fixed already:
 https://patchwork.kernel.org/patch/299172/

Andrew picked it up.

Regards,
Flo
