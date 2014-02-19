From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 0/4] net: bridge / ip optimizations for
 virtual net backends
Date: Wed, 19 Feb 2014 09:10:03 -0800
Message-ID: <CAB=NE6Wp+qypMkjkXc9QjnnLRjkS_PRMQLbj0QGnR8KTTaL5oA@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <5301E411.5060908@citrix.com> <CAB=NE6VxNByeWGk6_Ow7WgxA3HCwGBjrjL9MNVRGsEfFyeKTdw@mail.gmail.com>
 <1392803304.23084.95.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Vrabel <david.vrabel@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392803304.23084.95.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 19, 2014 at 1:48 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Tue, 2014-02-18 at 11:43 -0800, Luis R. Rodriguez wrote:
>>
>> New motivation: removing IPv4 and IPv6 from the backend interfaces can
>> save up a lot of boiler plate run time code, triggers from ever taking
>> place, and simplifying the backend interaces. If there is no use for
>> IPv4 and IPv6 interfaces why do we have them? Note: I have yet to test
>> the NAT case.
>
> I think you need to do that test that before you can unequivocally state
> that there is no use for IPv4/6 interfaces here.

Agreed but note that Zoltan stated that in the routing case IPv4 or
IPv6 addresses can be used on the backends, so that already rules that
out. Unless of course we want to enable this by default (for
simplicity) and have userpace poke to get out IPv4 / IPv6 if by
default no interfaces were enabled. Even though backend interfaces
would stand to gain on the average situation from this simplicity I
don't think the userspace requirements are worth it. Someone with
hundreds of guests (that don't do routing on the backend as clarified
by Zoltan) may want to test my patch though to see if there's any
reasonable cuts on getting these guests up and running.

Anyone itching for the above?

  Luis
