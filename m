From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [ethtool PATCH] FW dump support
Date: Wed, 4 May 2011 11:15:59 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD3990@EXMAIL.ad.emulex.com>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>,<1304530807.2926.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <--no-chain-reply-to@mv.qlogic.com>,
	<davem@davemloft.net>, <bhutchings@solarflare.com>
To: <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:3223 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755150Ab1EDSQU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:16:20 -0400
In-Reply-To: <1304530807.2926.28.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] On Behalf Of Ben Hutchings [bhutchings@solarflare.com]
Sent: Wednesday, May 04, 2011 12:40 PM
To: anirban.chakraborty@qlogic.com
Cc: netdev@vger.kernel.org; --no-chain-reply-to@mv.qlogic.com; davem@davemloft.net
Subject: Re: [ethtool PATCH] FW dump support

> On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
>> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>>
>> Added support to take FW dump via ethtool.
> [...]
>> --- a/ethtool.c
>> +++ b/ethtool.c
> [...]
>> @@ -263,6 +270,12 @@ static struct option {
>>               "Get Rx ntuple filters and actions\n" },
>>      { "-P", "--show-permaddr", MODE_PERMADDR,
>>               "Show permanent hardware address" },
>> +    { "-W", "--get-dump", MODE_GET_DUMP,
>> +             "Get dump level\n" },
>> +    { "-Wd", "--get-dump-data", MODE_GET_DUMP_DATA,
>> +             "Get dump data", "FILENAME " "Name of the dump file\n" },
>
> The short options should only include one letter.  Also the general
> pattern is that 'get' options use lower-case letters and 'set' options
> use upper-case letters.  No, I'm not sure how best to handle a set of 3
> options.  Maybe you can combine --get-dump and --get-dump-data, making
> the filename optional?

ethtool already has "-f" option to flash/write the FW image.
Can you use "-F" to get the FW dump data out?
And then may be, these options can be extended to get the get/set dump levels?

-Ajit