From: Tobias Klauser <klto@zhaw.ch>
Subject: Re: [PATCH] netfilter: ebtables: Use print_mac instead of own function
Date: Thu, 16 Jul 2009 09:25:14 +0200
Message-ID: <4A5ED5DA.303@zhaw.ch>
References: <1247655306-21337-1-git-send-email-klto@zhaw.ch> <4A5DF1FC.3050404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: bart.de.schuymer@pandora.be, shemminger@linux-foundation.org,
	davem@davemloft.net, ebtables-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A5DF1FC.3050404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/15/2009 05:13 PM, Patrick McHardy wrote:
> Tobias Klauser wrote:
>> ebt_log uses its own implementation of print_mac to print MAC addresses.
>> This patch converts it to use print_mac from linux/if_ether.h
> 
> You can do this even simpler by using %pM as format string.

Sorry, I didn't know about that one. I'll send an updated patch.

Thanks for the hint.

Tobias

