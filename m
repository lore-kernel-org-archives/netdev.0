From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 17:35:54 +0200
Message-ID: <20151005153554.GM2278@nanopsycho.orion>
References: <20150930135141.GF2098@nanopsycho.orion>
 <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
 <20151005095633.GE2278@nanopsycho.orion>
 <20151005144941.GC8673@lunn.ch>
 <20151005145542.GJ2278@nanopsycho.orion>
 <20151005145842.GD8673@lunn.ch>
 <20151005151821.GK2278@nanopsycho.orion>
 <56129745.1020805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, "Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35819 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbJEPf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:35:57 -0400
Received: by wicge5 with SMTP id ge5so126383439wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:35:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56129745.1020805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 05:29:09PM CEST, john.fastabend@gmail.com wrote:
>On 15-10-05 08:18 AM, Jiri Pirko wrote:
>> Mon, Oct 05, 2015 at 04:58:42PM CEST, andrew@lunn.ch wrote:
>>> On Mon, Oct 05, 2015 at 04:55:42PM +0200, Jiri Pirko wrote:
>>>> Mon, Oct 05, 2015 at 04:49:41PM CEST, andrew@lunn.ch wrote:
>>>>>>> Are you referring here to messages of the EMAD protocol ?
>>>>>
>>>>> I know nothing about this protocol.....
>>>>>
>>>>> Does it at least use standard Ethernet framing? Source and Destination
>>>>> header and an EtherType which mean EMAD?
>>>>
>>>> Yep, but that does not really matter. I believe we should find debugging
>>>> interface which is protocol agnostic. Just arbitrary messages
>>>> monitoring.
>>>
>>> Hi Jiri
>>>
>>> O.K, it is just that you mentioned wireshark. Passing the frames to
>>> network interface taps would make this trivial.
>> 
>> That is true. But using netlink+nlmon would do the same.
>
>Also I guess if you go this direction you want to make it generic
>enough for any drivers to use it to snoop software/firmware msgs. This
>is common across many devices.

Yes, definitelly, this should be something generic to be usable for
every device type.


>
>In the past though I've just used ethtool dump commands and some
>"scripts" on top of this to debug devices. And when it got really
>bad wrote some throw away code to debug my issue. I guess it might
>be nice to have something in the kernel to improve this but have
>you considered using the tracing features that already exist?

Which ones do you have in mind?


>
>.John
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
