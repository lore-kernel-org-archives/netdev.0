From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 17:44:59 +0200
Message-ID: <20140826154459.GB1843@nanopsycho.lan>
References: <53FAA2A2.7070801@gmail.com>
 <53FB3FD5.2030905@mojatatu.com>
 <20140825141754.GA30140@casper.infradead.org>
 <53FB6122.2040901@mojatatu.com>
 <20140825225057.GD30140@casper.infradead.org>
 <53FC909D.8090000@cumulusnetworks.com>
 <20140826140630.GA1848@nanopsycho.lan>
 <53FCA0AE.9010304@mojatatu.com>
 <20140826152217.GA1843@nanopsycho.lan>
 <53FCA7C6.5070804@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>,
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
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:50432 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaHZPpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:45:03 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so14536924wgh.26
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 08:45:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53FCA7C6.5070804@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 26, 2014 at 05:29:10PM CEST, jhs@mojatatu.com wrote:
>On 08/26/14 11:22, Jiri Pirko wrote:
>
>>I do not think that really matters. Phase one is flows. After that we
>>can focus on l2/l3. If we would be able to fit in in flows (some drivers
>>may), then ok. If not, we extend the api with couple of more l2/l3
>>related ndos. I see no problem there.
>
>Well, it matters because we are proceeding to implement L2/3.
>i.e the simple stuff first. We dont have anything to show yet - but
>we will hopefully have some useful bit by Plumbers.
>So maybe best path forward is we talk then and see how we can merge
>efforts since we cant seem to agree at this point.

I think we are in agreement. We have two worlds: flows and l2/3. We need
both for sure. And my patchset adds an initial part of the first one.
The second one can be added later. I do not see any issues in that.
