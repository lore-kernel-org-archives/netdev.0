From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 16:29:39 -0700
Message-ID: <1399418979.15399.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140506032114.GP2382@two.firstfloor.org>
	 <20140505.232327.578134514220748085.davem@davemloft.net>
	 <20140506155703.GA20391@cloud>
	 <20140506.115941.428706504757835279.davem@davemloft.net>
	 <20140506164108.GA20536@cloud> <20140506191447.GB4137@netboy>
	 <20140506195049.GO19657@tassilo.jf.intel.com>
	 <20140506200738.GA17813@netboy>
	 <20140506210549.GR19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, josh@joshtriplett.org,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506210549.GR19657@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-06 at 14:05 -0700, Andi Kleen wrote:

> - Make GRO optional.
> This is purely a performance feature for high bandwidth.

Make this properly then, instead of relying on LTO.

We did preliminary work to put this stuff in separate files, but its not
complete yet.

tcpv4_offload has pointers to tcp4_gro_receive() and tcp4_gro_complete()

Is LTO smart enough to understand this will never be called, and do
proper code elimination of whole _gro_ helpers ?
