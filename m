From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 21 Sep 2005 18:44:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0509211843530.13764@schroedinger.engr.sgi.com>
References: <43308324.70403@cosmosbay.com> <4331CFA7.50104@cosmosbay.com>
 <Pine.LNX.4.62.0509211542210.13045@schroedinger.engr.sgi.com>
 <20050921.173408.122945960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, linux-kernel@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	ak@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965208AbVIVBpT@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050921.173408.122945960.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Sep 2005, David S. Miller wrote:

> From: Christoph Lameter <clameter@engr.sgi.com>
> Date: Wed, 21 Sep 2005 15:43:29 -0700 (PDT)
> 
> > Maybe we better introduce vmalloc_node() instead of improvising this for 
> > several subsystems? The e1000 driver has similar issues.
> 
> I agree.

I did an implementation in June.

See http://marc.theaimsgroup.com/?l=linux-mm&m=111766643127530&w=2

Not sure if this will fit the bill. Never really tested it.
