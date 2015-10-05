From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 17:18:21 +0200
Message-ID: <20151005151821.GK2278@nanopsycho.orion>
References: <20150930135141.GF2098@nanopsycho.orion>
 <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
 <20151005095633.GE2278@nanopsycho.orion>
 <20151005144941.GC8673@lunn.ch>
 <20151005145542.GJ2278@nanopsycho.orion>
 <20151005145842.GD8673@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37707 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbJEPSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:18:25 -0400
Received: by wicfx3 with SMTP id fx3so119481682wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:18:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151005145842.GD8673@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 04:58:42PM CEST, andrew@lunn.ch wrote:
>On Mon, Oct 05, 2015 at 04:55:42PM +0200, Jiri Pirko wrote:
>> Mon, Oct 05, 2015 at 04:49:41PM CEST, andrew@lunn.ch wrote:
>> >> >Are you referring here to messages of the EMAD protocol ?
>> >
>> >I know nothing about this protocol.....
>> >
>> >Does it at least use standard Ethernet framing? Source and Destination
>> >header and an EtherType which mean EMAD?
>> 
>> Yep, but that does not really matter. I believe we should find debugging
>> interface which is protocol agnostic. Just arbitrary messages
>> monitoring.
>
>Hi Jiri
>
>O.K, it is just that you mentioned wireshark. Passing the frames to
>network interface taps would make this trivial.

That is true. But using netlink+nlmon would do the same.
