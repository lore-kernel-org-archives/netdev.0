From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 8 Apr 2004 17:38:27 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404081338.RAA16267@yakov.inr.ac.ru>
References: <20040401131657.GB18585@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se (Robert Olsson),
        dipankar@in.ibm.com (Dipankar Sarma),
        davem@redhat.com (David S. Miller), linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andrea@suse.de (Andrea Arcangeli)
In-Reply-To: <20040401131657.GB18585@dualathlon.random> from "Andrea Arcangeli" at сав 01, 2004 03:16:57 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This sounds reasonable. However as a start I was thinking at having
> hardirq run only the softirq they posted actively, and local_bh_enable
> run only the softirq that have been posted by the critical section (not
> from hardirqs happening on top of it).

To all that I remember Ingo insisted that the run from local_bh_enable() 
is necessary for softirqs triggered by hardirqs while softirqs are disabled.
Otherwise he observed random delays and redundant scheduler activity
breaking at least tux fast path.

Alexey
