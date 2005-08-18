From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: overflows in /proc/net/dev
Date: Thu, 18 Aug 2005 15:13:01 -0700
Message-ID: <20050818151301.23c4bc1e@dxpl.pdx.osdl.net>
References: <1124350090.29902.8.camel@basti79.freenet-ag.de>
	<20050818163358.GA19554@taniwha.stupidest.org>
	<20050818.143248.58283961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cw@f00f.org, Sebastian.Classen@freenet-ag.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932491AbVHRWNK@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050818.143248.58283961.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Aug 2005 14:32:48 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Chris Wedgwood <cw@f00f.org>
> Date: Thu, 18 Aug 2005 09:33:58 -0700
> 
> > I thought the concensurs here was that because doing reliable atomic
> > updates of 64-bit values isn't possible on some (most?) 32-bit
> > architectures so we need additional locking to make this work which is
> > undesirable?  (It might even be a FAQ by now as this comes up fairly
> > often).
> 
> That's correct.

Also width of fields in /proc/net/dev can't change without potentially
breaking ABI of applications.
