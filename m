From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Fri, 29 Aug 2014 10:20:55 -0400
Message-ID: <54008C47.5040503@mojatatu.com>
References: <20140825225057.GD30140@casper.infradead.org> <53FC909D.8090000@cumulusnetworks.com> <20140826140630.GA1848@nanopsycho.lan> <53FCA0AE.9010304@mojatatu.com> <20140826152217.GA1843@nanopsycho.lan> <53FCA7C6.5070804@mojatatu.com> <20140826154459.GB1843@nanopsycho.lan> <20140826155426.GA5275@gospo.rtplab.test> <20140826161956.GA15316@casper.infradead.org> <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com> <20140826205419.GH15316@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, ben@decadent.org.uk,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>, jasowang@redhat.
To: Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:40045 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbaH2OVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 10:21:00 -0400
Received: by mail-pa0-f51.google.com with SMTP id rd3so6674131pab.10
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 07:21:00 -0700 (PDT)
In-Reply-To: <20140826205419.GH15316@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/14 16:54, Thomas Graf wrote:
> On 08/26/14 at 01:13pm, Alexei Starovoitov wrote:
>> I think it's important distinction. In-kernel OVS is not OF.
>> It's a networking function that has hard-coded packet parser,
>> N-tuple match and programmable actions.
>> There were times when HW vendors were using OF check-box
>> to sell more chips, but at the end there is not a single HW
>> that is fully OF compliant. OF brand is still around, but
>> OF 2.0 is not tcam+action anymore.
>> Imo trying to standardize HW offload interface based on OF 1.x
>> principles is strange.


I actually have no issues with whatever classifier someone decides
to use. To each their poison. But I do take issue mandating the
specified classifer it as THE CLASSIFIER as in this case,
is where i start taking issue. I have a few things that i offload
to hardware with speacilized classifiers such that i object strongly
to the approach this driver has taken.

cheers,
jamal
