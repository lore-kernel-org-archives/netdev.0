From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Tue, 11 Jun 2002 23:26:40 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae6prl$isk$2@main.gmane.org>
References: <Pine.LNX.4.44.0206120905510.29780-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Mielke <mark@mark.mielke.cc>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
List-Id: netdev.vger.kernel.org



Pekka Savola wrote:


> Just to chime in my support (not that I don't think anyone needs it), I 
> think socket-based counters are An Extremely Bad Idea.  


Several folks have produced arguments with details showing how they
can use the counters to better their product and/or debugging.  Just
waving your hands and saying you don't like it does not invalidate
their claims.  Please go back and read the thread and then, if you're
able, put forth some valid arguments for how to accomplish the goals
in some other manner, or show the negatives of including the feature.

If they are useful to some people, and have zero performance affect on others
(due to being a configurable kernel feature), then what is your
complaint?

I see two reasons left to dislike this feature:

1)  General increase in #ifdef'd code.  This actually seems like
    a pretty good argument, but I haven't seen anyone mention it
    specifically.

2)  General dislike for a feature that one personally has no use for.
    Seems to be Dave's main (professed) excuse.


Please add to this list, but back up your claims.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
