From: Harry Edmon <harry@atmos.washington.edu>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 09:40:29 -0700
Message-ID: <4496D37D.7090400@atmos.washington.edu>
References: <4492D5D3.4000303@atmos.washington.edu> <20060617153511.53a129a3.akpm@osdl.org> <44948EF6.1060201@atmos.washington.edu> <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dew1.atmos.washington.edu ([128.95.89.41]:47070 "EHLO
	dew1.atmos.washington.edu") by vger.kernel.org with ESMTP
	id S964792AbWFSQkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 12:40:40 -0400
To: Jesper Dangaard Brouer <hawk@diku.dk>
In-Reply-To: <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jesper Dangaard Brouer wrote:
>
>>> Harry Edmon <harry@atmos.washington.edu> wrote:
>>>
>>>> I have a system with a strange network performance degradation from 
>>>> 2.6.11.12 to most recent kernels including 2.6.16.20 and 
>>>> 2.6.17-rc6. The system is has Dual single core Xeons with 
>>>> hyperthreading on.
> <cut>
>
> Hi Harry
>
> Can you check which "high-res timesource" you are using?
>
> In the kernel log look for:
>  kernel: Using tsc for high-res timesource
>  kernel: Using pmtmr for high-res timesource
>
> I have experinced some network performance degradation when using the 
> "pmtmr" timesource, on a Opteron AMD system.  It seems that the 
> default timesource change between 2.6.15 to 2.6.16.
>
> If you use "pmtmr" try to reboot with kernel option "clock=tsc".
>
> On my Opteron AMD system i normally can route 400 kpps, but with 
> timesource "pmtmr" i could only route around 83 kpps.  (I found the 
> timer to be the issue by using oprofile).
>
>
We have CONFIG_HPET_TIMER=y, so we do not see these messages.


