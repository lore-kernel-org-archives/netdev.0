From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Stupid netstat question
Date: Mon, 21 Oct 2002 14:16:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB46EB1.69B820FE@us.ibm.com>
References: <BAB65108CB1677418CC9060BB51C21D92F57E6@dens700.corp.sbvc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ian Nelson <ian@latis.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ian Nelson wrote:
> 
> What exactly does the TCPSchedulerFailed metric mean?

> I'm building a network appliance that is doing a lot of nmap and nessus
> type stuff and I'm getting an extreme number of TCPSchedulerFailed and
> TCPAbortOnData.  I've been tracking what I think is a bug in an Ethernet
> driver but I'm starting to think it's a software problem in application
> land.

Its the number of packets that are prequeued (partially completed
tcp processing, waiting for a recvmsg to complete & send ack etc)
when the delayed ack timer goes off. i.e I think, the thinking is
this shouldnt happen, since the delayed ack timer really shouldnt 
go off - the receiver should have picked up the skb's and sent 
the acks. I'm probably off by a mile here..Dont know.

It may be related to the AbortOnData counts. Are you closing apps
with linger off or something?

thanks,
Nivedita
