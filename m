From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 20:33:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.203325.41658167.davem@redhat.com>
References: <3EE682B8.8060708@candelatech.com>
	<20030610.182234.74725315.davem@redhat.com>
	<3EE68B15.60802@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EE68B15.60802@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   
   Yes, I understand why we want a time-stamp very early...but if
   we can get _some_ sort of time stamp very cheap (TSC, for example)
   then we can potentially defer the more expensive conversion of
   this stamp into the equivalent of whatever do_gettimeofday will
   give us.

I fully understand your idea, I've talked about it with Alexey many
times.  Someone just has to implement it.

pkt_sched.h is probably the place to play, maybe make an
asm/pkt_sched.h header.
