From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv2 net-next-2.6 2/2] qlcnic: Take FW dump via ethtool
Date: Tue, 10 May 2011 15:19:19 -0700
Message-ID: <1C54C9D7-3B1B-47EC-98F5-0A621932D9D4@qlogic.com>
References: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304989352-24810-4-git-send-email-anirban.chakraborty@qlogic.com>
 <1305052826.2859.53.camel@bwh-desktop>
 <3D85CC75-765C-4059-BB3F-82CCBF748FBC@qlogic.com>
 <1305064696.2859.90.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:7072
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090Ab1EJWTX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 18:19:23 -0400
In-Reply-To: <1305064696.2859.90.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 10, 2011, at 2:58 PM, Ben Hutchings wrote:

>>>> <snip>
>>> 
>>> This doesn't seem to be serialised with the code that captures firmware
>>> dumps.  They need to use the same lock!
>> When we take the dump, we bring down the interface. So, ethtool will not get a chance to
>> fetch the dump data while the dump operation is in progress.
> [...]
> 
> The ethtool core generally doesn't care whether the interface is
> running.  Its operations are serialised only by the RTNL lock.  The work
> item you added to extract a dump from the NIC does not take that lock.

Oh, ok. Thanks for pointing that out.

-Anirban


