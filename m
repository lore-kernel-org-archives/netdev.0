From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/13] rocker: add support for multiple worlds
Date: Tue, 6 Oct 2015 09:30:18 +0200
Message-ID: <20151006073018.GA2165@nanopsycho.orion>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAymAKeKBOwPP11QDvBYR-iCMg3VD_7qBZH+n_+f-x9WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37942 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbJFHaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:30:22 -0400
Received: by wiclk2 with SMTP id lk2so145944200wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:30:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAymAKeKBOwPP11QDvBYR-iCMg3VD_7qBZH+n_+f-x9WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 06, 2015 at 05:56:12AM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> This patchset allows new rocker worlds to be easily added in future (like eBPF
>> based one I have been working on). The main part of the patchset is the OF-DPA
>> carve-out. It resuts in OF-DPA specific file. Clean cut.
>>
>> v1->v2:
>>  - rtnl rocker mode change userspace expose patch was removed
>>
>> Jiri Pirko (13):
>>   rocker: remove unused rocker_port param from alloc funcs and shorten
>>     their names
>>   rocker: rename rocker.h to rocker_hw.h
>>   rocker: rename rocker.c to rocker_main.c
>>   rocker: push tlv processing into separate files
>>   rocker: implement set settings mode command
>>   rocker: introduce worlds infrastructure
>>   rocker: introduce OF-DPA world skeleton
>>   rocker: set default world on port probe and clean world on remove
>>   rocker: pass "learning" value as a parameter to
>>     rocker_port_set_learning
>>   rocker: pre-allocate wait structures during cmd ring init
>>   rocker: remove trans parameter to rocker_cmd_exec function
>>   rocker: call rocker_cmd_exec function with "nowait" boolean instead of
>>     flags
>>   rocker: move OF-DPA stuff into separate file
>
>A couple of my tests are failing with this patchset.  A simple port
>test is failing and IPv4 routing test is failing.
>
>The port test is simple: just connect a port on DUT to a port on
>another system and assign an IP address to each port and verify IP
>connectivity.  I have this:
>
>   DUT:sw1p1 (11.0.0.1/24) <-----------> host1:eth0 (11.0.0.2/24)
>
>The IPv4 routing tests is a bit more complicated to setup.  I'm using
>OSPF, but I'm not seeing full routes formed in the topology, so I
>suspect OSPF hellos aren't getting thru.
>
>Please fix find/fix these issues and send v3.  I don't want any git
>bisect issues when running tests.  Thanks.

I fixed that. Sending v3 in a sec. Thanks.
