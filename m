From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH V2 net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver
Date: Thu, 5 Jun 2014 08:03:51 -0500
Message-ID: <53906AB7.20508@amd.com>
References: <20140604161130.6242.57741.stgit@tlendack-t1.amdoffice.net>
	<20140604.143605.960519678688904189.davem@davemloft.net>
 <20140604.143903.1213688714066322891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <jcm@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0206.outbound.protection.outlook.com ([207.46.163.206]:9988
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751641AbaFENE2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 09:04:28 -0400
In-Reply-To: <20140604.143903.1213688714066322891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/04/2014 04:39 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 04 Jun 2014 14:36:05 -0700 (PDT)
>
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>> Date: Wed, 4 Jun 2014 11:11:31 -0500
>>
>>> The following series implements support for the new AMD 10Gb Ethern=
et
>>> driver (amd-xgbe).  It includes the 10Gb Ethernet driver as well as
>>> a 10Gb Ethernet PHY driver.
>>>
>>> This patch series is based on net-next.
>>>
>>> Changes in V2:
>>>    - Add phy-mode to the amd-xgbe device bindings
>>>    - Obtain the phy-mode from the device tree
>>>    - Reference ethernet.txt device bindings for phy-handle and phy-=
mode
>>>    - Connect/disconnect to/from phy during probe/remove, instead of=
 open/close
>>>    - Fixes for jumbo packet support / MTU changes
>>>    - Formatting changes for debug packet dump
>>>    - Free resources in the phylib driver remove function
>>>    - Proper NP NULL message during auto-negotiation
>>
>> Series applied, thanks.
>
> I had to revert, this breaks the build:
>
> drivers/net/phy/amd-xgbe-phy.c: In function =A1amd_xgbe_phy_probe=A2:
> drivers/net/phy/amd-xgbe-phy.c:1251:2: error: implicit declaration of=
 function =A1of_dev_put=A2 [-Werror=3Dimplicit-function-declaration]
> cc1: some warnings being treated as errors
> make[3]: *** [drivers/net/phy/amd-xgbe-phy.o] Error 1
> make[2]: *** [drivers/net/phy] Error 2
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [drivers/net] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [drivers] Error 2
>

Sorry about that, I'll fix the config dependencies and send out a
V3.

Tom
