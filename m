From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 16:47:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
References: <4492D5D3.4000303@atmos.washington.edu> <20060617153511.53a129a3.akpm@osdl.org>
 <44948EF6.1060201@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932507AbWFSOrw@vger.kernel.org>
To: Harry Edmon <harry@atmos.washington.edu>
In-Reply-To: <44948EF6.1060201@atmos.washington.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> Harry Edmon <harry@atmos.washington.edu> wrote:
>> 
>>> I have a system with a strange network performance degradation from 
>>> 2.6.11.12 to most recent kernels including 2.6.16.20 and 2.6.17-rc6. 
>>> The system is has Dual single core Xeons with hyperthreading on.
<cut>

Hi Harry

Can you check which "high-res timesource" you are using?

In the kernel log look for:
  kernel: Using tsc for high-res timesource
  kernel: Using pmtmr for high-res timesource

I have experinced some network performance degradation when using the 
"pmtmr" timesource, on a Opteron AMD system.  It seems that the default 
timesource change between 2.6.15 to 2.6.16.

If you use "pmtmr" try to reboot with kernel option "clock=tsc".

On my Opteron AMD system i normally can route 400 kpps, but with 
timesource "pmtmr" i could only route around 83 kpps.  (I found the timer 
to be the issue by using oprofile).


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
