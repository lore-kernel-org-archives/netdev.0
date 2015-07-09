From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 5/5] switchdev: update documentation for offload_fwd_mark
Date: Wed, 8 Jul 2015 22:57:09 -0700
Message-ID: <CAE4R7bDf=ZZgv+4KHCLOkQjxWYmF8P7oo1_2rUkpnYnguZJQuA@mail.gmail.com>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
 <1436397403-62412-6-git-send-email-sfeldma@gmail.com> <20150709042723.GB16603@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35579 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbGIF5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 01:57:30 -0400
Received: by oihr66 with SMTP id r66so126383656oih.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 22:57:29 -0700 (PDT)
In-Reply-To: <20150709042723.GB16603@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 9:27 PM, Simon Horman <simon.horman@netronome.com> wrote:
> On Wed, Jul 08, 2015 at 04:16:43PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>>  Documentation/networking/switchdev.txt |   14 ++++++++++++--
>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
>> index c5d7ade..b864e47 100644
>> --- a/Documentation/networking/switchdev.txt
>> +++ b/Documentation/networking/switchdev.txt
>> @@ -279,8 +279,18 @@ and unknown unicast packets to all ports in domain, if allowed by port's
>>  current STP state.  The switch driver, knowing which ports are within which
>>  vlan L2 domain, can program the switch device for flooding.  The packet should
>>  also be sent to the port netdev for processing by the bridge driver.  The
>> -bridge should not reflood the packet to the same ports the device flooded.
>> -XXX: the mechanism to avoid duplicate flood packets is being discuseed.
>> +bridge should not reflood the packet to the same ports the device flooded,
>> +otherwise there will be duplicate packets on the wire.
>> +
>> +To avoid duplicate packets, the device/driver can mark a packet as already
>
> I wonder if  'should' or 'may' would be clearer than 'can'.

'should' sounds better; v2.
