From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 00/13] rocker: add support for multiple worlds
Date: Tue, 6 Oct 2015 10:14:39 -0700
Message-ID: <CAE4R7bDTF9tt-G+9vXQ-jfkHVg=sL06DPzmA6gfSWvhDEz95OQ@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAymAKeKBOwPP11QDvBYR-iCMg3VD_7qBZH+n_+f-x9WA@mail.gmail.com> <20151006073018.GA2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35661 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbbJFRPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 13:15:00 -0400
Received: by oiww128 with SMTP id w128so112567857oiw.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 10:14:59 -0700 (PDT)
In-Reply-To: <20151006073018.GA2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 12:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 06, 2015 at 05:56:12AM CEST, sfeldma@gmail.com wrote:
>>On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This patchset allows new rocker worlds to be easily added in future (like eBPF
>>> based one I have been working on). The main part of the patchset is the OF-DPA
>>> carve-out. It resuts in OF-DPA specific file. Clean cut.
>>>
>>> v1->v2:
>>>  - rtnl rocker mode change userspace expose patch was removed
>>>
>>> Jiri Pirko (13):
>>>   rocker: remove unused rocker_port param from alloc funcs and shorten
>>>     their names
>>>   rocker: rename rocker.h to rocker_hw.h
>>>   rocker: rename rocker.c to rocker_main.c
>>>   rocker: push tlv processing into separate files
>>>   rocker: implement set settings mode command
>>>   rocker: introduce worlds infrastructure
>>>   rocker: introduce OF-DPA world skeleton
>>>   rocker: set default world on port probe and clean world on remove
>>>   rocker: pass "learning" value as a parameter to
>>>     rocker_port_set_learning
>>>   rocker: pre-allocate wait structures during cmd ring init
>>>   rocker: remove trans parameter to rocker_cmd_exec function
>>>   rocker: call rocker_cmd_exec function with "nowait" boolean instead of
>>>     flags
>>>   rocker: move OF-DPA stuff into separate file
>>
>>A couple of my tests are failing with this patchset.  A simple port
>>test is failing and IPv4 routing test is failing.
>>
>>The port test is simple: just connect a port on DUT to a port on
>>another system and assign an IP address to each port and verify IP
>>connectivity.  I have this:
>>
>>   DUT:sw1p1 (11.0.0.1/24) <-----------> host1:eth0 (11.0.0.2/24)
>>
>>The IPv4 routing tests is a bit more complicated to setup.  I'm using
>>OSPF, but I'm not seeing full routes formed in the topology, so I
>>suspect OSPF hellos aren't getting thru.
>>
>>Please fix find/fix these issues and send v3.  I don't want any git
>>bisect issues when running tests.  Thanks.
>
> I fixed that. Sending v3 in a sec. Thanks.

Sorry, both tests are still broken.  Would you send me your tests
scripts so I can see why your tests are passing?
