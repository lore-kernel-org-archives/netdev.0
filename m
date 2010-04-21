From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 21 Apr 2010 15:17:00 +0200
Message-ID: <4BCEFACC.7020804@trash.net>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	John Haxby <john.haxby@oracle.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Wednesday 2010-04-21 14:59, Patrick McHardy wrote:
> 
>> Jan Engelhardt wrote:
>>> The SYSRQ target will allow to remotely invoke sysrq on the local
>>> machine. Authentication is by means of a pre-shared key that can
>>> either be transmitted plaintext or digest-secured.
>> I really think this is pushing what netfilter is meant for a bit
>> far. Its basically abusing the firewall ruleset to offer a network
>> service.
>>
>> I can see that its useful to have this in the kernel instead of
>> userspace, but why isn't this implemented as a stand-alone module?
>> That seems like a better design to me and also makes it more useful
>> by not depending on netfilter.
> 
> That sort of diverts from the earlier what-seemed-to-be-consensus.
> 
> Oh well, I would not mind holding the single commit up as long as the 
> rest isn't blocked too :-)

Then lets skip this one for now.
