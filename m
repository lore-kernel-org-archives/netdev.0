From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Wed, 26 Nov 2014 21:50:34 +0000
Message-ID: <20141126215034.GA32174@casper.infradead.org>
References: <5474A567.4040401@mojatatu.com>
 <20141125164954.GJ1971@nanopsycho.orion>
 <5474B795.3080204@mojatatu.com>
 <20141125215402.GA3912@casper.infradead.org>
 <54754A10.6020601@mojatatu.com>
 <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
 <5475BB53.3070200@mojatatu.com>
 <20141126160859.GB13786@casper.infradead.org>
 <54760939.8050805@mojatatu.com>
 <20141126175944.GW1875@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linvi
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34915 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaKZVun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 16:50:43 -0500
Content-Disposition: inline
In-Reply-To: <20141126175944.GW1875@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 06:59pm, Jiri Pirko wrote:
> Wed, Nov 26, 2014 at 06:09:13PM CET, jhs@mojatatu.com wrote:
> >On 11/26/14 11:08, Thomas Graf wrote:
> >>On 11/26/14 at 06:36am, Jamal Hadi Salim wrote:
> >>What is irriating in this context is that you are pushing back on
> >>Jiri and others while referring to properitary and closed code which
> >>you are unwilling or unable to share. I don't see this as being
> >>passive aggressive, everybody is treated the same way in this regard.
> >
> >WTF? I said i have hardware that is not a switch because it doesnt
> >do switching. This all started with the name being "switch" which
> >I objected to. You ask me to describe hardware and then you come
> >back and say I am using that to stop progress?
> 
> Stay calm, I'm sure that this is just a misunderstanding.
> 
> >Where the hell did i push back on Jiri? Stop going around
> >telling people i do.

You are requesting a name change for a proprietary driver after
confirming that you can't publish the code. We don't even know what
the piece of hardware you refer to is capable of.

We've always written driver facing APIs for the drivers that are
*in* the kernel which in this case is rocker, modelled after OF-DPA,
existing NIC drivers, and DSA drivers.

I can live with the term switch, but if somebody can come up with a
better name, cool. "Chip" or "ASIC" are probably not better choices
though.
