From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Unaligned accesses in the ethernet bridge
Date: Fri, 7 Apr 2006 16:57:11 -0700
Message-ID: <20060407165711.1df5b52e@dxpl.pdx.osdl.net>
References: <17442.650.874609.271109@berry.ken.nicta.com.au>
	<20060406203708.GA7118@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751351AbWDHAA6@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060406203708.GA7118@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Apr 2006 22:37:08 +0200
Adrian Bunk <bunk@stusta.de> wrote:

> On Thu, Mar 23, 2006 at 01:06:02PM +1100, Peter Chubb wrote:
> > 
> > I see lots of
> > 	kernel unaligned access to 0xa0000001009dbb6f, ip=0xa000000100811591
> > 	kernel unaligned access to 0xa0000001009dbb6b, ip=0xa0000001008115c1
> > 	kernel unaligned access to 0xa0000001009dbb6d, ip=0xa0000001008115f1
> > messages in my logs on IA64 when using the ethernet bridge with 2.6.16.
> > 
> > 
> > Appended is a patch to fix them.
> 
> 
> I see this patch already made it into 2.6.17-rc1.
> 
> It seems to be a candidate for 2.6.16.3, too?
> If yes, please submit it to stable@kernel.org.

The code that caused this was new in 2.6.17
