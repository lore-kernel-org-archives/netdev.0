From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 26 Sep 2014 22:02:47 +0100
Message-ID: <20140926210247.GA17546@casper.infradead.org>
References: <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
 <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
 <20140923041130.GA10808@gospo.home.greyhouse.net>
 <542192A3.2020309@mellanox.com>
 <20140924133246.GB4966@casper.infradead.org>
 <CAJ3xEMj0L_09ORvJhHPbcHociCsPN=H9QWui4BhnbWXSFzXDvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55748 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881AbaIZVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:02:59 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMj0L_09ORvJhHPbcHociCsPN=H9QWui4BhnbWXSFzXDvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/14 at 11:03pm, Or Gerlitz wrote:
> Yep, this can serve us for the architecture discussion @ LPC. Re the
> SRIOV case, you referred to the case where guest VF traffic goes
> through HW (say) VXLAN encap/decap -- just to make sure, we need also
> to support the simpler case, where guest traffic just goes through
> vlan tag/strip.

Agreed.

> The SRIOV case is only mentioned here in the "Compatibility with
> existing FDB ioctls for SR-IOV" bullet, so I'm a bit nervous... we
> need to have it clear in the agenda.

I think the offload API discussion should consider the SR-iOV case
but we might need to discuss additional details outside of that
BoF to ensure that the BoF can keep focus on the offload API itself.
That said, I suggest we define the specific agenda once we know that
the BoF has been accepted and 2 hours have been allocated ;-)

> Also, this BoF needs to be double-len, two hours, can you act to
> get that done?

This has already been requested.
