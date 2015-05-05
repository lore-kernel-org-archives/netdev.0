From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 20/21] rocker: make checkpatch -f clean
Date: Tue, 5 May 2015 20:13:21 +0200
Message-ID: <20150505181321.GB2764@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-21-git-send-email-sfeldma@gmail.com>
 <1430847947.3943.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36757 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbbEESN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 14:13:27 -0400
Received: by wizk4 with SMTP id k4so172264563wiz.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 11:13:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847947.3943.4.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:45:47PM CEST, joe@perches.com wrote:
>On Tue, 2015-05-05 at 10:34 -0700, sfeldma@gmail.com wrote:
>> Well almost clean: ignore the CHECKs for space after cast operator.
>
>I think, because this uses relatively long identifiers,
>that you might as well ignore > 80 column lines length
>warnings.
>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>[]
>> @@ -1418,9 +1418,10 @@ static int rocker_event_link_change(struct rocker *rocker,
>>  	if (!attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT] ||
>>  	    !attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP])
>>  		return -EIO;
>> -	port_number =
>> -		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT]) - 1;
>> -	link_up = rocker_tlv_get_u8(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);
>> +	port_number = rocker_tlv_get_u32(
>> +		attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT]) - 1;
>> +	link_up = rocker_tlv_get_u8(
>> +		attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);
>
>These would probably be better on single lines.

I agree. Let this be on single line.

>
>Maybe it'd be OK to avoid the rocker_tlv_ prefix

I'd like to have that prefix.

>and/or add a helper macro/define for the
>	rocker_tlv_<foo>(attrs[ROCKER_TLV_<BAR>
>style to shorten the line length.

Not sure about the macros, they obfuscate things :/
