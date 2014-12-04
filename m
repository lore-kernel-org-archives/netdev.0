From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu, 04 Dec 2014 06:22:19 -0800
Message-ID: <54806E1B.5010402@cumulusnetworks.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <54805EB6.2010901@mojatatu.com> <20141204135621.GQ27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37840 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbaLDOWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 09:22:39 -0500
In-Reply-To: <20141204135621.GQ27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 5:56 AM, Andy Gospodarek wrote:
> On Thu, Dec 04, 2014 at 08:16:38AM -0500, Jamal Hadi Salim wrote:
>> General comment:
>> iproute2 patches need to be addressed to the maintainer
>> stephen@networkplumber.org
>> And are we mainstream enough now we can drop the 1000 people on the
>> To: list? I doubt most of these people are even following the discussion (I
>> planted an easter egg for Aviad and didnt see him
>> reacting) ;->
> I actually don't mind them coming here since it is a change to netlink.
> Thanks for sending them to netdev, Jiri.

I think jamal meant the people in the cc (not netdev).
I actually like the cc, but that probably cant last long because it is a 
lot of people.
>
>> cheers,
>> jamal
>>
>> On 12/04/14 03:57, Jiri Pirko wrote:
>>> Jiri Pirko (1):
>>>    iproute2: ipa: show switch id
>>>
>>> Scott Feldman (5):
>>>    bridge/fdb: fix statistics output spacing
>>>    bridge/fdb: add flag/indication for FDB entry synced from offload
>>>      device
>>>    bridge/link: add new offload hwmode swdev
>>>    link: add missing IFLA_BRPORT_PROXYARP
>>>    bridge/link: add learning_sync policy flag
>>>
>>>   bridge/fdb.c              |  4 +++-
>>>   bridge/link.c             | 17 +++++++++++++++--
>>>   include/linux/if_bridge.h |  1 +
>>>   include/linux/if_link.h   |  3 +++
>>>   include/linux/neighbour.h |  1 +
>>>   ip/ipaddress.c            |  8 ++++++++
>>>   man/man8/bridge.8         | 19 ++++++++++++++-----
>>>   7 files changed, 45 insertions(+), 8 deletions(-)
>>>
