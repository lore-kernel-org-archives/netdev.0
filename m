From: Lincoln Dale <ltd@cisco.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Mon, 10 Jun 2002 22:03:25 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <5.1.0.14.2.20020610220015.040aff60@mira-sjcm-3.cisco.com>
References: <3D039D22.2010805@candelatech.com>
 <3D029DAF.5040006@candelatech.com>
 <20020608.175108.84748597.davem@redhat.com>
 <3D039D22.2010805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: greearb@candelatech.com, mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020609.213440.04716391.davem@redhat.com>
List-Id: netdev.vger.kernel.org

At 09:34 PM 9/06/2002 -0700, David S. Miller wrote:
>Every argument I hear is one out of lazyness.  And that is not a
>reason to add something.  Simply put, I don't want to add all of this
>per-socket counter bumping that only, at best, 1 tenth of 1 percent
>of people will use.  This means that the rest of the world eats the
>overhead just for this small group that actually uses it.

would you be willing to accept a patch that enables per-socket accounting 
with a CONFIG_ option?

to my mind, i can see a number of perfectly valid scenarios.
one is for streaming-media applications which could use retransmissions as 
an indication to buffer more data and/or switch to a different bitrate.

another is for a http proxy which has multiple outgoing interfaces which 
are multihomed via different providers (and some via simplex satellite).
retransmissions woud be a nice metric to use for determining the weightings 
between using different interfaces.


cheers,

lincoln.
