From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Tue, 25 Mar 2014 22:48:07 -0700
Message-ID: <53326A17.5030406@cumulusnetworks.com>
References: <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <CAGVrzcacuU=RsnBOQh2-u+AjsMvznUYWFJru86w09+Vpdta2KQ@mail.gmail.com> <20140325194018.GG8102@hmsreliant.think-freely.org> <CAGVrzca3g8GMgoO8ptzmvCLusTJRzb9C0Duh+bXUrQPtB4LyaQ@mail.gmail.com> <20140325213958.GE15723@casper.infradead.org> <5331FE69.30505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf <tgraf@suug.ch>, Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy <andy@greyhouse.net>,
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
	Felix Fietkau <nbd@openwrt.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48880 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaCZFsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 01:48:12 -0400
In-Reply-To: <5331FE69.30505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/25/14, 3:08 PM, Jamal Hadi Salim wrote:
> On 03/25/14 17:39, tgraf wrote:
>> On 03/25/14 at 01:00pm, Florian Fainelli wrote:
>
>>
>> I think all it takes is to correctly apply the existing separation
>> which is already available but not applied right now.
>>
>> We already have the L2/L3 separation in place:
>>
>> net_device vs in_device/inet6_dev/....
>>
>> A pure L2 device that will never do L3 on the CPU would only
>> need to set a flag which we check before allocating a in_device
>> and therefore prevent from all the L3 configs to be exposed.
>
>
> I think we need much deeper discussion on the topic of other
> functions that may not be directly connected to netdevs
> (v4/6 forwarding, ACL, etc).

Agreed.  Some of our generic switch api challenges have been in these areas.

thanks,
Roopa
