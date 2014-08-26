From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 15:20:27 +0100
Message-ID: <20140826142027.GA1012@casper.infradead.org>
References: <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com>
 <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <20140825145449.GB30140@casper.infradead.org>
 <53FB68EB.9060308@mojatatu.com>
 <20140825221148.GC30140@casper.infradead.org>
 <53FC931A.3020903@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50703 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758354AbaHZOUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:20:34 -0400
Content-Disposition: inline
In-Reply-To: <53FC931A.3020903@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/14 at 10:00am, Jamal Hadi Salim wrote:
> >I would argue that swflow is a superset of a Netlink route. It
> >may infact be very useful to extend the API with something that
> >understands the Netlink representation of a route and have the
> >API translate that to a classifier that can be offloaded.
> >
> 
> Sorry Thomas, I disagree.
> A route has a lot more knobs than just a simple flow representation.
> We are talking next hops (of which there could be multiple) etc.
> There is no way you can boil that down to a simple flow representation.

I guess we could argue forever.

To answer your specific statement. If per (wildcard) flow nexthop
balancing behaviour is good enough, the current flow insert is likely
sufficient. If the hardware should do the balancing, an additional
API function is probably needed to cleanly represent that.
