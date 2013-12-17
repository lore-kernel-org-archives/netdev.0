From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Tue, 17 Dec 2013 15:01:05 -0500 (EST)
Message-ID: <20131217.150105.1449726906478334082.davem@davemloft.net>
References: <20131213133453.GB7332@order.stressinduktion.org>
	<20131213134205.GB11044@sirena.org.uk>
	<20131213141227.GC7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, mark.hambleton@broadcom.com,
	pshelar@nicira.com, Saran.Neti@telus.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131213141227.GC7332@order.stressinduktion.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 13 Dec 2013 15:12:27 +0100

> On Fri, Dec 13, 2013 at 01:42:05PM +0000, Mark Brown wrote:
>> On Fri, Dec 13, 2013 at 02:34:53PM +0100, Hannes Frederic Sowa wrote:
>> 
>> > Sorry, I don't know which version the LTS kernel is. Upstream does not use
>> > sk_buff_data_t for mac_header any more.
>> 
>> This is with v3.10.
> 
> The change happend in 3.11. So I guess it was an oversight while backporting.
> Following patch should help and should get backported to all stable kernels
> <= 3.10.
> 
> [PATCH stable] ipv6: fix illegal mac_header comparison on 32bit
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Queued up for -stable, thanks Hannes.
