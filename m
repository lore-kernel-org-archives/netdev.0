From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 23:15:33 +0000
Message-ID: <20140326231533.GA11773@casper.infradead.org>
References: <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org>
 <20140326182122.GC31370@hmsreliant.think-freely.org>
 <CAGVrzcYNW0Z96mL-MecY=mte=+TcFn8k3eSY4pqi9h0N2jF7hw@mail.gmail.com>
 <53335838.3060409@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
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
	Felix Fietkau <nbd@openwrt.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50731 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbaCZXPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 19:15:37 -0400
Content-Disposition: inline
In-Reply-To: <53335838.3060409@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 at 06:44pm, Jamal Hadi Salim wrote:
> OTOH, the owrt view is probably because (If i understood correctly
> last time), there are cases where there is no way to even pass packets
> and attribute them to the originating switch ports. Infact, in some
> cases  there may be no way at all to even pass packets to the kernel.
> Did i  understand that part correctly?
> I suppose this is eventually all part of that capability discovery.

Listening to Florian it sounds like the fact that a separate control
path was chosen early on in owrt got rid of the main driver to abstract
everything through globally visible net_devices. Reusing existing
tools was never an objective.

I believe that the question whether a particular port will send
packets to the cpu does not matter that much. We'll see both and we'll
see various forms of hybrid models with software based learnings paths,
slow paths, and deliberate upcalls.

The simpler the model, the better. If the desire to hide some of the
complexity is driven by usability when I believe that hiding should
happen in user space.
