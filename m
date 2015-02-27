From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH 1/3] Documentation: dts: Update compatible field
 description for APM X-Gene
Date: Fri, 27 Feb 2015 15:58:28 -0800
Message-ID: <CAKh23FmLE-s_C5YUjLTQLT0_P9DT6LzmaBxJPRWY4AwXK9jQNA@mail.gmail.com>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
	<1425067710-14879-2-git-send-email-isubramanian@apm.com>
	<20150227201516.GA30683@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"mlangsdo@redhat.com" <mlangsdo@redhat.com>,
	"patches@apm.com" <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og107.obsmtp.com ([64.18.0.184]:52184 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755630AbbB0X6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:58:31 -0500
Received: by lbjb6 with SMTP id b6so20343773lbj.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 15:58:28 -0800 (PST)
In-Reply-To: <20150227201516.GA30683@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 12:15 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Feb 27, 2015 at 08:08:28PM +0000, Iyappan Subramanian wrote:
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
>> ---
>>  Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> index cfcc527..5355996 100644
>> --- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> @@ -4,7 +4,8 @@ Ethernet nodes are defined to describe on-chip ethernet interfaces in
>>  APM X-Gene SoC.
>>
>>  Required properties for all the ethernet interfaces:
>> -- compatible: Should be "apm,xgene-enet"
>> +- compatible: Should be "apm,xgene-enet", "apm,xgene1-sgenet" or
>> +  "apm,xgene1-xgenet"
>
> Please format this as a list. It'll be easier to read, and you can add
> more later.

Thanks.  I will do that.

>
> What are the diffences between these variants?

apm,xgene-enet - binding for RGMII based 1G interface
apm,xgene1-sgenet - binding for SGMII based 1G interface
apm,xgene1-xgenet - binding for XFI based 10G interface


>
> Mark.
>
>>  - reg: Address and length of the register set for the device. It contains the
>>    information of registers in the same order as described by reg-names
>>  - reg-names: Should contain the register set names
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
