From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Tue, 23 Sep 2014 11:11:29 +0100
Message-ID: <20140923101129.GD6944@casper.infradead.org>
References: <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
 <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
 <20140923041130.GA10808@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
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
	Florian Fainelli <f.fainelli@gmail.com>,
	Roop
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59960 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270AbaIWKLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 06:11:34 -0400
Content-Disposition: inline
In-Reply-To: <20140923041130.GA10808@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/14 at 12:11am, Andy Gospodarek wrote:
> There are clearly some that are most interested in how an eSwitch on an
> SR-IOV capable NIC be controlled can provide traditional forwarding help
> as well as offload the various technologies they hope to terminate
> at/inside their endpoint (host/guest/container) -- Thomas's _simple_
> use-case demonstrates this. ;)  This is a logical extention/increase in
> functionality that is offered in many eSwitches that was previously
> hidden from the user with the first generation SR-IOV capable network
> devices on hosts/servers.

I think we can define this more broadly and state that providing RX
steering capabilities to identify a guest in the NIC allows to
directly map packets into a memory region shared between host and
guest. Not a new concept at all but the existing dMAC and VLAN rx
filtering is just too limiting. We require a programmable API with
support for encap and encryption. SR-IOV is a hardware assisted form
of that which can expedite the guest to guest path on a host.
