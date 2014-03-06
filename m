From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Thu, 06 Mar 2014 13:07:46 -0500 (EST)
Message-ID: <20140306.130746.1333492573211031660.davem@davemloft.net>
References: <7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
	<20140305.193913.470467212827707623.davem@redhat.com>
	<20140306111139.2b7b6b8b@zoidberg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbaCFSHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 13:07:48 -0500
In-Reply-To: <20140306111139.2b7b6b8b@zoidberg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Thu, 6 Mar 2014 11:11:39 +0100

> On Wed, 05 Mar 2014 19:39:13 -0500 (EST)
> David Miller <davem@redhat.com> wrote:
> 
>> This is how we handle some fields of struct iphdr, and it's fine with
>> me.
> 
> Wonderful, this will unclutter everything that concerns itself with
> some degree of header handling.
> 
>> Be sure to use __LITTLE_ENDIAN_BITFIELD and __BIG_ENDIAN_BITFIELD for
>> your CPP checks.
> 
> I looked at struct iphdr now that you mentioned it, and i was a little
> surprised to see that this header is often pointer-cast from an
> skb_network_header.

Why is that surprising?  It's the network header.

> As far as I can see, declaring all subfields (say)
> u16 in the bitfield endianness order when the entire bitfield is a u16
> in the header will result in correct behaviour for cast/memcpy. Is this
> correct? If not, I'll write out explicit operations for each bitfield
> member.

memcpy() "just works"
