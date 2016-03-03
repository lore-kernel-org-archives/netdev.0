From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [PATCH] fsl/fman: remove dTSEC-A003 Errata workaround
Date: Thu, 3 Mar 2016 19:55:42 +0000
Message-ID: <HE1PR0401MB1931EE7D0AC0DEC9D7DE460691BD0@HE1PR0401MB1931.eurprd04.prod.outlook.com>
References: <1456696781-32384-1-git-send-email-igal.liberman@freescale.com>
 <DB5PR0401MB19282E4987BDCEBBBF7EBCC591BA0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
 <AM4PR04MB20970739740D5E5BEAE53678ECBC0@AM4PR04MB2097.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "scottwood@freescale.com" <scottwood@freescale.com>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>,
	Thomas Trefny <tom.trefny@nxp.com>
To: Igal Liberman <igal.liberman@nxp.com>,
	"igal.liberman@freescale.com" <igal.liberman@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0065.outbound.protection.outlook.com ([157.55.234.65]:42880
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750865AbcCCTzr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 14:55:47 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2016 10:15 AM, Igal Liberman wrote:
>> -----Original Message-----
>> From: Scott Wood [mailto:scott.wood@nxp.com]
>> Sent: Tuesday, March 01, 2016 1:31 AM
>> To: igal.liberman@freescale.com; netdev@vger.kernel.org
>> Cc: scottwood@freescale.com; madalin.bucur@freescale.com
>> Subject: Re: [PATCH] fsl/fman: remove dTSEC-A003 Errata workaround
>>
>> On 02/29/2016 09:17 AM, igal.liberman@freescale.com wrote:
>>> From: Igal Liberman <igal.liberman@freescale.com>
>>>
>>> Errata dTSEC-A003 was fixed in P4080 rev 3.0.
>>> Prior revisions are not supported, so the workaround can be removed.
>>>
>>> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
>>
>> Since when do we not support p4080 rev 2?
>>
> 
> Hi Scott,
> According to the following link, only rev 3 part numbers are "Active". Rev 2 part numbers are either "Not recommended for New Design" or "No Longer Manufactured".

That doesn't mean we deliberately break them on newer kernels.

> In addition,
> P4080 rev 2 was removed in SDK 1.5 (2013). This can be seen here (requires registration):
> https://freescale.sdlproducts.com/LiveContent/web/pub.xql?c=t&action=home&pub=QorIQ_SDK_1.9&lang=en-US#addHistory=true&filename=GUID-21A68B1F-4CD4-4959-9175-406D8FCD9A7A.xml&docid=GUID-21A68B1F-4CD4-4959-9175-406D8FCD9A7A&inner_id=&tid=&query=&scope=&resource=&toc=false&eventType=lcContent.loadDocGUID-21A68B1F-4CD4-4959-9175-406D8FCD9A7A
> Click on "Supported Targets" and scroll down to P4080.

This isn't the SDK.  The SDK has been aggressively dropping support for
older chips.

-Scott
