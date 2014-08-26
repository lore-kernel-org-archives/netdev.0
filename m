From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 10:58:54 -0400
Message-ID: <53FCA0AE.9010304@mojatatu.com>
References: <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org> <53FA01AC.10507@mojatatu.com> <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com> <53FAA2A2.7070801@gmail.com> <53FB3FD5.2030905@mojatatu.com> <20140825141754.GA30140@casper.infradead.org> <53FB6122.2040901@mojatatu.com> <20140825225057.GD30140@casper.infradead.org> <53FC909D.8090000@cumulusnetworks.com> <20140826140630.GA1848@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, Shrijeet Mukherjee <
To: Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48291 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934497AbaHZO65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:58:57 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so22545412pde.10
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:58:56 -0700 (PDT)
In-Reply-To: <20140826140630.GA1848@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/14 10:06, Jiri Pirko wrote:

> Yes. Flows are phase one. The api will be extended in for whatever is
> needed for l2/l3 as you said. Also I see a possibility to implement the
> l2/l3 use case with flows as well.

And as a note: This is where i have the disagreement.
It is good there is acknowledgement you are handling flows for now.
Or whatever tuples you defined as "flow". I dont think L2 or 3 fit
in that. If thats not what you are saying then we are in agreement.

cheers,
jamal
