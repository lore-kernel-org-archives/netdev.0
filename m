From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/24] net, diet: Make ping sockets optional
Date: Mon, 05 May 2014 23:04:27 -0400 (EDT)
Message-ID: <20140505.230427.1025985660046509545.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-8-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-8-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:56 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> This saves about 6k text/data. ping still works fine using raw
> sockets like it always did.
> 
>    text	   data	    bss	    dec	    hex	filename
>  268128	  11555	   7872	 287555	  46343	net/ipv4/built-in.o-noping
>  273610	  11843	   8176	 293629	  47afd	net/ipv4/built-in.o-ping
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Sorry, not applying this, it's been discussed already, and it's
exactly small'ish systems that want this facility.

We want to move away from raw sockets, and making this optional
is not going to help us move forward down that path.
