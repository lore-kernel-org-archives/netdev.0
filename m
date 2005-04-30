From: jamal <hadi@cyberus.ca>
Subject: Re: Pktgen receive hook in dev.c?
Date: Fri, 29 Apr 2005 20:14:18 -0400
Message-ID: <1114820059.8929.17.camel@localhost.localdomain>
References: <4272C384.50901@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4272C384.50901@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-29-04 at 16:30 -0700, Ben Greear wrote:
> I am curious if there is any interest in adding a hook in the netif_receive_skb
> method to allow receiving (and consuming) pktgen packets.  This gives the ability
> to get some good packet receive & latency stats using pktgen.
> 
> I asked this a year or so ago and was told no, but since then the netpoll and
> TC_NCLS hooks have been added.... so maybe hooks are OK again?
> 

Write an action. It should be trivial to consume pktgen. Infact if all
you wanted was to count, use the gact action.

cheers,
jamal
