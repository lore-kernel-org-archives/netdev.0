From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 13:28:58 -0400
Message-ID: <52179BDA.50603@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com> <52178E20.5040404@gmail.com> <52179448.1020906@ti.com> <5217974B.5090503@ti.com> <521799A3.7080706@ti.com> <52179AD6.8090406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <netdev@vger.kernel.org>,
	<bcousson@baylibre.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:32981 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab3HWR30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 13:29:26 -0400
In-Reply-To: <52179AD6.8090406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 August 2013 01:24 PM, Daniel Mack wrote:
> On 23.08.2013 19:19, Santosh Shilimkar wrote:
>> On Friday 23 August 2013 01:09 PM, Sekhar Nori wrote:
>>> On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:
> 
>>>> So just stick the IP version or call it cpsw-v1... cpsw-v2 etc.
>>>
>>> If this could be handled using IP version then the right way would be to
>>> just read the IP version from hardware and use it. No need of DT property.
>>>
>> Thats fine as well but I thought the patch needed additional properties like
>> CM reg-address come from DT and hence the separate compatible. If you can
>> manage without that, thats even better.
> 
> We can't, that's the whole point :)
> 
I saw that from the patch :)

> Well, theoretically, we could for now, but that's not a clean solution.
> Again: the problem here is that the control port is separated from the
> cpsw core, and so we have to implement something specific for the AM3352
> SoC. I know that's a violation of clean and generic driver ideas, but
> there's no way we can assume that every cpsw v2 ip block has a control
> port that is compatible to the one found on am335x chips.
> 
But there is a possibility that other SOC will just use the same
control module approach. So using a revision IP is just fine. BTW,
CPSW is not the only driver where control module is used. There are
many examples like USB, MMC etc

There is nothing wrong in using the version info and associating
the additional functionality with it.

Regards,
Santosh
