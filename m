From: "Mala Anand" <manand@us.ibm.com>
Subject: Re: [Lse-tech] Re: (RFC): SKB Initialization
Date: Mon, 26 Aug 2002 21:53:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <47991.3249765106$1030418364@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "Bill Hartner" <bhartner@us.ibm.com>, davem@redhat.com,
   jamal <hadi@cyberus.ca>, linux-kernel@vger.kernel.org,
   "Mala Anand" <manand@us.ibm.com>, netdev@oss.sgi.com,
   Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Robert Olsson wrote..
 >In slab terms you moved part of the destructor to the constructor
 >but the main problem is still there. The skb entered the "wrong" CPU
 >so to be "reused from the slab again" the work has to done regardless
 >if it's in the constructor or destructor.
That is true if it is a uni processor but in smp the initialization,
if happened in two different CPUs, affects performance due to cache
effects.

The problem of object (skb) allocation, usage and deallocation occurring
in multiple CPUs need to be addressed separately. This patch is not
attempting to address that.

 >Eventually if we accept some cache misses a skb could possibly be
re-routed
 >to the proper slab/CPU for this we would need some skb coloring.
You still can do this. I don't see skbinit patch hindering this.

Regards,
    Mala


   Mala Anand
   IBM Linux Technology Center - Kernel Performance
   E-mail:manand@us.ibm.com
   http://www-124.ibm.com/developerworks/opensource/linuxperf
   http://www-124.ibm.com/developerworks/projects/linuxperf
   Phone:838-8088; Tie-line:678-8088
