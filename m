From: Ben Greear <greearb@candelatech.com>
Subject: Re: cheap 4-port tulip-based cards available
Date: Sat, 19 Oct 2002 14:59:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB1D5DC.6040800@candelatech.com>
References: <slrnaqpajf.2ph.lunz@stoli.localnet> <3DB1C96B.4070505@candelatech.com> <20021019141417.A11659@synapse.neuralscape.com> <3DB1CF5A.9080701@candelatech.com> <20021019144236.C11659@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Karen Shaeffer <shaeffer@neuralscape.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Karen Shaeffer wrote:
> On Sat, Oct 19, 2002 at 02:32:10PM -0700, Ben Greear wrote:
> 
>>Karen Shaeffer wrote:
>>
>>>On Sat, Oct 19, 2002 at 02:06:51PM -0700, Ben Greear wrote:
>>>
>>
>>I make traffic generators out of them (www.candelatech.com)
>>
>>They are also good for firewalls and routers, as well as more
>>exotic network devices.  Using linux for a switch does not make so
>>much sense these days when you can buy a 16 port switch for under $100,
>>but with bridging code it can be done.
> 
> 
> Actually, I think linux based switches could be quite interesting in
> a pipelined, beowulf-like or openmosix cluster. (Of course, GigE would
> probably be employed rather than FE.) You could then integrate traffic
> shaping/monitoring functionality into the switch that could be designed
> to interoperate with the cluster nodes to assist in optimizing data flow
> and subsequent processing. With openmosix, this could also be used to
> migrate processes towards optimum node placement, based on network
> traffic analysis as well as nodal resource availability.
> 
> It's a subject I've been thinking about quite a bit lately. This is most
> interesting in adaptive, pipelined clusters that will be processing
> real-time streaming data. That's certainly a niche market at the present
> time.

Right now, you'll have a tough time getting a single GigE NIC to run line
speed, full duplex.

However, I've thought about writing a controlling process that monitors
and dynamically configures a switch though SNMP or some other API.  That way,
you could migrate machines across LANs/VLANs to better distribute your traffic.

And, you could keep all your traffic running line speed (or however fast
your switches run)

> 
> cheers,
> Karen


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
