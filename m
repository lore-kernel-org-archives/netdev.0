From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 2 Apr 2014 12:54:50 -0700
Message-ID: <3C265410-A9DF-489F-BC55-05B231564D12@cumulusnetworks.com>
References: <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion> <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com> <533C1F91.6000704@greyhouse.net> <20140402152546.GB3596@tuxdriver.com> <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com> <20140402192915.GB3301@tuxdriver.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34876 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932688AbaDBT45 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 15:56:57 -0400
In-Reply-To: <20140402192915.GB3301@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 2, 2014, at 12:29 PM, John W. Linville <linville@tuxdriver.com> =
wrote:

> Cool!  I'm glad we agree.  Now we just need some switch hardware
> drivers that fit the general model outlined above...

Why wait?  Let=92s create a switch device in qemu and then write the mo=
del/sample driver to that.  Put a PCI front end on the qemu device whic=
h is mapped to kernel, and define a register set to represent all the s=
witch-like ops we want to offload, in a generic way.  Throw in some DMA=
 for CPU-bound I/O (ctrl traffic).  On the qemu device back end, expose=
 the ports as taps or whatever so we can wire to real-world link partne=
rs on the host side.

> I would be happy to maintain a kernel.org git tree as a nursery for
> such drivers as they develop and mature, and I'm sure my daytime
> employer would be happy to support me on that.  I wonder if we can
> get any switch people from Intel, Mellanox, Broadcom, or elsewhere
> to play along?

My gut tells me this is a build-it-and-they-will-come situation.

-scott