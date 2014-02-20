From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Thu, 20 Feb 2014 12:28:37 -0800
Message-ID: <CAB=NE6U7WsN80SOoDrDYvEj9tYYdmcLriCtS-tvLDVeqGmdfwA@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<53024C58.4010900@citrix.com>
	<CAB=NE6XYjOd2vRpQCZOG-S5ZW4xjam+FOPAYzribNQpb50Q5pg@mail.gmail.com>
	<5306156B.4070105@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5306156B.4070105@citrix.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 20, 2014 at 6:47 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> On 19/02/14 16:45, Luis R. Rodriguez wrote:
>
>> You seem to describe a case whereby it can make sense for xen-netback
>> interfaces to end up becoming the root port of a bridge. Can you
>> elaborate a little more on that as it was unclear the use case.
>
> Well, I might be wrong on that, but the scenario I was thinking: a guest
> (let's say domain 1) can have multiple interfaces on different Dom0 (or
> driver domain) bridges, let's say vif1.0 is plugged into xenbr0 and vif1.1
> is in xenbr1. If the guest wants to make a bridge of this two, then using
> STP makes sense.

The bridging would happen on the front end in that case no?

>  I wanted to bring up CloudStack's virtual router as an
> example, but then I realized it's probably doesn't do such thing. However I
> don't think we should hardcode that a netback interface can't be RP ever.

My patch did allow for this but the root block flag that Stephen
mentioned can always be lifted.

  Luis
