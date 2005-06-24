From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] dst numa: Avoid dst counter cacheline bouncing
Date: Thu, 23 Jun 2005 22:05:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506232204320.30382@graphe.net>
References: <Pine.LNX.4.62.0506231953260.28244@graphe.net>
 <Pine.LNX.4.62.0506232005030.28244@graphe.net> <20050624045854.GA6465@in.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, shai@scalex86.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263105AbVFXFGn@vger.kernel.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
In-Reply-To: <20050624045854.GA6465@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Jun 2005, Dipankar Sarma wrote:

> Do we really need to do a distributed reference counter implementation
> inside dst cache code ? If you are willing to wait for a while,
> we should have modified Rusty's bigref implementation on top of the 
> interleaving dynamic per-cpu allocator. We can look at distributed 
> reference counter for dst refcount then and see how that can be 
> worked out.

Is that code available somewhere?
