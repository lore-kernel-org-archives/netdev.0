From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 17:51:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE67D2D.80608@candelatech.com>
References: <16102.9418.43884.336925@robur.slu.se> <20030610.115759.26513736.davem@redhat.com> <Pine.LNX.4.51.0306101725020.17226@ns.istop.com> <20030610.152020.59678979.davem@redhat.com> <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
   "Robert.Olsson@data.slu.se" <Robert.Olsson@data.slu.se>,
   "hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
   "xerox@foonet.net" <xerox@foonet.net>,
   "sim@netnation.com" <sim@netnation.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> On Tue, 10 Jun 2003, David S. Miller wrote:
> 
> 
>>   From: Ralph Doncaster <ralph@istop.com>
>>   What's the do_gettimeofday for?
>>
>>Every packet records a timestamp.
> 
> 
> I'm not aware of anything in IP routing that requires a timestamp for
> every packet.  To me it sounds like we could rip that out too.
> 
> -Ralph
> 

Maybe as a configurable option, since it would make tcpdump less useful.
Seems like we could kludge it up so that we used the TSC (or whatever that
really fast hardware clock is) to provide some relative stamp that could be
converted to a time_val later?

It does seem a bit wasteful to do the gettimeofday when most of the time
the result is ignored.

(Or, are there things other than tcpdump that need the gettimeofday stamp?)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
