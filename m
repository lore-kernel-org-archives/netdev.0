From: Rabin Vincent <rabin@rab.in>
Subject: Re: [PATCH] net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
Date: Tue, 5 Jan 2016 17:03:45 +0100
Message-ID: <20160105160345.GA3951@debian>
References: <1452007387-626-1-git-send-email-rabin@rab.in>
 <1452009645.8255.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
	ast@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
	sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452009645.8255.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 05, 2016 at 08:00:45AM -0800, Eric Dumazet wrote:
> On Tue, 2016-01-05 at 16:23 +0100, Rabin Vincent wrote:
> > The SKF_AD_ALU_XOR_X ancillary is not like the other ancillary data
> > instructions since it XORs A with X while all the others replace A with
> > some loaded value.  All the BPF JITs fail to clear A if this is used as
> > the first instruction in a filter.
> 
> Is x86_64 part of this 'All' subset ? ;)

No, because it's an eBPF JIT.
