From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 15:03:03 -0700
Message-ID: <42AA0E17.8050201@hp.com>
References: <42A8E0FE.3020708@candelatech.com>	<1118361376.5838.20.camel@rh4>	<42A8EBDA.6010306@candelatech.com>	<1118363861.5838.29.camel@rh4>	<42AA016C.9050801@candelatech.com> <42AA0743.1020101@hp.com> <42AA0C9D.2060006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42AA0C9D.2060006@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> There will be a bridge chip, and indeed I see better performance when I just 
> use a 2-port Intel NIC as opposed to a 4 port, even if I am only actively 
> using 2 of the 4 ports on the 4-port NIC.  For the tg3 hardware I only have a
> 4-port NIC.  I do assume that a 2-port tg3 NIC w/out a bridge chip would be
> faster..but probably not too much.

I have been taught by several wise old engineers that the proper spelling of 
assume is ass-u-me :)

Bridge chips can in theory do all sorts of nasty things to performance.

> CKO == IP checksum offload?


Yes.


> Since Dave doesn't want to debug my bridge setup (and I don't blame him), I
> am going to try to focus my testing/debug reports on the pktgen tests. 
> If/when pktgen shows better performance with tg3, I can verify that I see the
> same speedups with my proprietary bridging module.  I've no idea if CKO would
> help or hinder pktgen, nor have I tried to enable or disable it.
> 
>> Are your interface interrupts distributed across the CPUs?
> 
> 
> I'm using FC2, basically a default install.  It does seem to have an irq
> balance daemon running.  But, I'm not specifically binding IRQs or anything
> like that.  pktgen tx is running as a single thread, so the rx code could run
> mostly on the other CPU if locking allows...

again, never ass-u-me.

rick
