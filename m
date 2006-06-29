From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make net/core/skbuff.c:skb_release_data() static
Date: Thu, 29 Jun 2006 13:03:02 -0700 (PDT)
Message-ID: <20060629.130302.84973515.davem@davemloft.net>
References: <20060623105623.GT9111@stusta.de>
	<20060623.040115.108744369.davem@davemloft.net>
	<20060629192020.GR19712@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932378AbWF2UDF@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060629192020.GR19712@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 29 Jun 2006 21:20:20 +0200

> On Fri, Jun 23, 2006 at 04:01:15AM -0700, David Miller wrote:
> > From: Adrian Bunk <bunk@stusta.de>
> > Date: Fri, 23 Jun 2006 12:56:23 +0200
> > 
> > > skb_release_data() no longer has any users in other files.
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > If you are going to do this, you need to remove the reference
> > in arch/x86_64/kernel/functionlist too.
> > 
> > Thanks.
> 
> Corrected patch below.

Applied, thanks.
