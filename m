From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v1 1/2] dtb: xgene: fix: Disable 10GbE and SGMII based
 1GbE by default
Date: Mon, 3 Nov 2014 11:45:44 -0800
Message-ID: <CAKh23FkVrPdCuR6dn1S4RvW14_f4Xq8MWaChUh9DyVp44kVtSg@mail.gmail.com>
References: <1414630580-24640-1-git-send-email-isubramanian@apm.com>
	<1414630580-24640-2-git-send-email-isubramanian@apm.com>
	<1991367.DGHysZpQVP@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>, patches <patches@apm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og125.obsmtp.com ([64.18.0.245]:48351 "HELO
	exprod5og125.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752340AbaKCTpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:45:46 -0500
Received: by mail-lb0-f177.google.com with SMTP id z12so1462045lbi.22
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 11:45:44 -0800 (PST)
In-Reply-To: <1991367.DGHysZpQVP@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Thu, Oct 30, 2014 at 3:13 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday 29 October 2014 17:56:19 Iyappan Subramanian wrote:
>> @@ -621,7 +621,7 @@
>>                         };
>>                 };
>>
>> -               sgenet0: ethernet@1f210000 {
>> +               sgenet0: sgenet@1f210000 {
>>                         compatible = "apm,xgene-enet";
>>                         status = "disabled";
>>                         reg = <0x0 0x1f210000 0x0 0x10000>,
>>
>
> This looks like you accidentally reverted a bug fix made earlier.
> Network devices should always have the name 'ethernet@...'.

Thanks for the review.  Since our firmware was patching the dtb, based
on the node-name, we thought by changing node-name, we can avoid the
patching and maintain backward compatibility.

Now we know that network devices should have 'ethernet@...', we will
handle the backward compatibility in a different way and will post the
patch v2 shortly.

>
>         Arnd
