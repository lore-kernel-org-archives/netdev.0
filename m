From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: Allow stmmac to work with other PHY buses(v2).
Date: Thu, 08 Mar 2012 15:03:05 +0100
Message-ID: <4F58BC19.1050702@st.com>
References: <1331012520-19574-1-git-send-email-peppe.cavallaro@st.com> <20120306.165703.277843706808689044.davem@davemloft.net> <4F57178C.7010407@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39724 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab2CHODv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 09:03:51 -0500
In-Reply-To: <4F57178C.7010407@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2012 9:08 AM, Srinivas KANDAGATLA wrote:
> David Miller wrote:
>> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
>> Date: Tue,  6 Mar 2012 06:42:00 +0100
>>
>>   
>>> After commit "db8857b stmmac: use an unique MDIO bus name" and "90b9a54
>>> stmmac: fix phy naming inconsistency" stmmac cant work with other MDIO
>>> buses, because mdio_bus name is fixed in the dirver.
>>>     
>>
>> This sounds inaccurate, you're making it sound like these commits
>> introduced this limitation, as far as I can tell they did not.
>>
>>   
> Thanks for your comments,
> 
> Commit comment is true to some extent, before "db8857b stmmac: use an
> unique MDIO bus name" and "a77e929 mdio-gpio: use an unique MDIO bus
> name" we managed to get stmmac use mdio bus by specifying same id in
> platform data of both the drivers.
> However after these commits this method was no more possible because
> stmmac can connect to phys on stmmac-x mdio buses Only.
> 
> I think, originally the problem was in stmmac to some extent which
> became worse after adding prefix mdio bus.
> Here is the new patch removing the misleading comments.

Thx Srini to have resent the patch

peppe

> 
> 
>> Before the MDIO bus name was just plain "%x" and the bus_id number
>> was placed there.  Then it became the same thing, except with some
>> (potentially fixed) prefix.
>>
>> Nothing about that change makes any difference whatsoever about
>> what you're modifications are trying to allow.
>>
>> BTW, also, commit "90b9a54" is ambiguous.
>>
>>   
> Actual commit was : 90b9a5454fd2e626aa1614fe9ece6b63a0dc37af
> 
> Thanks,
> srini
>> [davem@bql net]$ git show 90b9a54
>> error: short SHA1 90b9a54 is ambiguous.
>> error: short SHA1 90b9a54 is ambiguous.
>> fatal: ambiguous argument '90b9a54': unknown revision or path not in the working tree.
>>   
> 
