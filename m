From: Andi Kleen <ak@suse.de>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 14:08:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611120803.GB22720@wotan.suse.de>
References: <3EE682B8.8060708@candelatech.com> <20030610.182234.74725315.davem@redhat.com> <3EE68B15.60802@candelatech.com> <20030610.203325.41658167.davem@redhat.com> <20030611065255.L39678@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20030611065255.L39678@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 11, 2003 at 07:54:53AM -0400, Jamal Hadi wrote:
> 
> Ok, time to go into another separate thread ;->
> 
> Sounds like a good idea.
> 
> if (skbneedstimestamp)
> 	do_gettimeofday(&skb->stamp);
> else
> 	defertimestamp()

Another way is to just store jiffies (= 10 or 1ms accuracy) 

This should be nearly zero cost and accurate enough at least for TCP.

-Andi
