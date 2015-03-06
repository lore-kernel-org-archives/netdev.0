From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 0/5] net: dsa: code re-organization
Date: Fri, 06 Mar 2015 06:50:24 -0800
Message-ID: <54F9BEB0.9060609@roeck-us.net>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com> <20150306.001855.2219598159441758214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr
To: David Miller <davem@davemloft.net>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39233 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbbCFOvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 09:51:14 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YTtar-003Do1-UJ
	for netdev@vger.kernel.org; Fri, 06 Mar 2015 14:51:14 +0000
In-Reply-To: <20150306.001855.2219598159441758214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 09:18 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu,  5 Mar 2015 12:35:03 -0800
>
>> This pull request contains the first part of the patches required to implement
>> the grand plan detailed here:
>>
>> http://www.spinics.net/lists/netdev/msg295942.html
>>
>> These are mostly code re-organization and function bodies re-arrangement to
>> allow different callers of lower-level initialization functions for 'struct
>> dsa_switch' and 'struct dsa_switch_tree' to be later introduced.
>>
>> There is no functional code change at this point.
>
> Looks great, applied, thanks Florian.
>
I applied the series (and all other pending dsa patches) on top of 4.0-rc2
and tested the result. Everything is working fine.

Too late for the commit, but anyway

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter
