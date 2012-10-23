From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: Re: [PATCH net-next 01/15] 6lowpan: =?UTF-8?Q?lowpan=5Fis=5Fiid?=  =?UTF-8?Q?=5F=31=36=5Fbit=5Fcompressable=28=29=20does=20not=20detect=20co?=  =?UTF-8?Q?mpressable=20address=20correctly?=
Date: Tue, 23 Oct 2012 16:57:28 +0200
Message-ID: <0772aae75fdc88ed964d964e46f2cef0@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
 <1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
 <20121023.024945.1428104116658345802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	<linux-zigbee-devel@lists.sourceforge.net>, <alan@signal11.us>,
	<alex.bluesman.smirnov@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:54915 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757095Ab2JWO6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 10:58:24 -0400
In-Reply-To: <20121023.024945.1428104116658345802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Le 23.10.2012 08:49, David Miller a =C3=A9crit=C2=A0:
[...]
>
> It's really demoralizing to sit down to read a large 15 entry
> patch series and this is the first thing I see:
>
>>  /*
>> - * check whether we can compress the IID to 16 bits,
>> - * it's possible for unicast adresses with first 49 bits are zero=20
>> only.
>> - */
>> +* check whether we can compress the IID to 16 bits,
>> +* it's possible for unicast adresses with first 49 bits are zero=20
>> only.
>> +*/
>
> Don't break the comment indentation, it was perfectly fine.
>
> I'm not reviewing the rest of the series, you'll need to repost
> the entire thing after you fix this.
>
> And if you're smart you'll make sure there aren't similar coding
> style issues in the rest of your patches, else it's going to take
> a long time to merge this crap into the tree.

Sorry about that, I failed to catch that mistake of mine (and several=20
other ones that Jan spotted). I'll rework my patchset and resubmit.=20
Thank you for pointing out this issue.

Regards,
Tony
