From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sfc: report supported link speeds on SFP
 connections
Date: Wed, 08 Jun 2016 11:19:14 -0700 (PDT)
Message-ID: <20160608.111914.164051676271541750.davem@davemloft.net>
References: <20160606185529.GV56933@redhat.com>
	<20160607212016.GH56933@redhat.com>
	<20160608134114.GJ56933@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bkenward@solarflare.com, linux-kernel@vger.kernel.org,
	linux-net-drivers@solarflare.com, ecree@solarflare.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161084AbcFHSTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:19:15 -0400
In-Reply-To: <20160608134114.GJ56933@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Wed, 8 Jun 2016 09:41:14 -0400

> On Tue, Jun 07, 2016 at 05:20:16PM -0400, Jarod Wilson wrote:
>> On Mon, Jun 06, 2016 at 02:55:29PM -0400, Jarod Wilson wrote:
>> > On Mon, Jun 06, 2016 at 05:29:30PM +0100, Bert Kenward wrote:
>> > > 7000-series SFC NICs connected with an SFP+ module currently fail to
>> > > report any supported link speeds.
>> > > 
>> > > Reported-by: Jarod Wilson <jarod@redhat.com>
>> > > Signed-off-by: Bert Kenward <bkenward@solarflare.com>
>> > 
>> > Had a feeling my cut might not have been quite right. Looks good to me.
>> > 
>> > Reviewed-by: Jarod Wilson <jarod@redhat.com>
>> 
>> ...however, upon testing, there's a gotcha. This results in my 10Gbps sfc
>> nic reporting that it supports 40Gbps:
>> 
>> $ ethtool ens4f0
>> Settings for ens4f0:
>> 	Supported ports: [ FIBRE ]
>> 	Supported link modes:   1000baseT/Full
>> 	                        10000baseT/Full
>> 	                        40000baseKR4/Full
> 
> This turned out to be a flub on my part. My local tree wasn't clean, had
> some lingering test/debug crap in it that I thought I'd removed, but
> clearly, hadn't. With that removed, we're all good here.
> 
> Tested-by: Jarod Wilson <jarod@redhat.com>

Thanks for following up.

Applied, thanks everyone.
