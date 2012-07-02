From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH net-next 13/15] netfilter: nfdbus: Add D-bus message parsing
Date: Mon, 02 Jul 2012 17:43:43 +0200
Message-ID: <4FF1C1AF.9080104@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <1340988354-26981-14-git-send-email-vincent.sanders@collabora.co.uk> <20120629171108.GA6287@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629171108.GA6287@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/29/2012 07:11 PM, Pablo Neira Ayuso wrote:
> On Fri, Jun 29, 2012 at 05:45:52PM +0100, Vincent Sanders wrote:
>> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
>> 
>> The netfilter D-Bus module needs to parse D-bus messages sent by
>> applications to decide whether a peer can receive or not a D-Bus
>> message. Add D-bus message parsing logic to be able to analyze.
> 
> Not talking about the entire patchset, only about the part I'm
> responsible for.
> 
> I don't see why you think this belong to netfilter at all.
> 
> This doesn't integrate into the existing filtering infrastructure,
> neither it extends it in any way.
> 

Hello Pablo,

Thanks a lot for your feedback.

This is the first of a set of patches that adds a netfilter module to parse
D-Bus messages, the complete patch-set is:

[PATCH 13/15] netfilter: nfdbus: Add D-bus message parsing
[PATCH 14/15] netfilter: nfdbus: Add D-bus match rule implementation
[PATCH 15/15] netfilter: add netfilter D-Bus module

patches 13 and 14 just include D-Bus helper code to be used by the netfilter
module (added on patch 15) and specially the dbus_filter netfilter hook function.

For the next post version we will reorganize the patches so first the D-Bus
netfilter module is added with an empty dbus_filter function and then added the
D-Bus helper code.

Also, we will move the nfdbus netfilter module to net/bus so is not inside the
netfilter core code.

Thanks a lot and best regards,
Javier
