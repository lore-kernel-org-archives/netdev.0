From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 14:36:51 -0700
Message-ID: <550C92F3.50302@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, ronen.arad@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:32811 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbCTVg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:36:56 -0400
Received: by pdnc3 with SMTP id c3so119965002pdn.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:36:55 -0700 (PDT)
In-Reply-To: <20150320.163655.474336751434677390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15, 1:36 PM, David Miller wrote:
> From: roopa@cumulusnetworks.com
> Date: Fri, 20 Mar 2015 09:58:34 -0700
>
>> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
>> there is a need to not re-forward frames that have already been
>> forwarded in hardware.
> It's impossible to validate this without seeing a use case where
> the device marks packets appropriately in order to trigger this
> new code.
>
> And as John said, some devices may not even be able to do that.
agreed, and that's why I am still sending this patch as RFC and not
for inclusion right away.

since we have discussed this problem multiple times in switchdev meetings,
the intent of this RFC is to see get the code out and also see if rocker 
or any other in-kernel
driver can use it.

thanks,
Roopa
