From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 11:31:55 -0400
Message-ID: <20140326153155.GD12372@tuxdriver.com>
References: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com>
 <5332B1FE.7080102@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41130 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbaCZPpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:45:44 -0400
Content-Disposition: inline
In-Reply-To: <5332B1FE.7080102@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 06:54:54AM -0400, Jamal Hadi Salim wrote:
> On 03/26/14 01:37, Roopa Prabhu wrote:

> >Most cases the switch port driver (API) can talk to the switch chip
> >driver without a switch netdev in between.
> >But there are cases where a switch netdev might become necessary for
> >switch chip specific operations (which probably has been discussed on
> >this thread). An example could be a global acl rule that applies to all
> >switch ports. One can argue that this can be applied on individual
> >switch ports and the switch driver can take care of consolidating or
> >optimally programming the acl rule in the switch chip.
> >
> 
> There are a lot of things which dont tie to a specific port.
> I think these should be transparent to the chip. If i add a route
> and the decision is for that route to go to the chip, then it
> shows up at the driver and it goes to the ASIC.
> If i am dumping a fib table and some parts of it sit in the chip,
> then whatever interfaces would end up querying the chip.

Right -- I think the netdev portions of the switch hardware drivers can
be made smart enough to handle most of this stuff behind the scenes.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
