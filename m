From: "David S. Miller" <davem@redhat.com>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 20:29:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.202915.71117016.davem@redhat.com>
References: <3EE68B15.60802@candelatech.com>
	<20030610.203325.41658167.davem@redhat.com>
	<20030611065255.L39678@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030611065255.L39678@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Wed, 11 Jun 2003 07:54:53 -0400 (EDT)

   Sounds like a good idea.
   
   if (skbneedstimestamp)
   	do_gettimeofday(&skb->stamp);
   else
   	defertimestamp()
   
Damn, read the thread Jamal :(  This is not possible at all.

We do not know the value of 'skbneedstimestamp' until much later,
but we MUST make the timestamp now in order for it to be accurate.
