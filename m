From: Greg Dietsche <gregory.dietsche@cuw.edu>
Subject: Re: [PATCH 1/2] iwlegacy: change IWL_WARN to IWL_DEBUG_HT in iwl4965_tx_agg_start
Date: Mon, 29 Aug 2011 08:33:39 -0500
Message-ID: <4E5B9533.6000109@cuw.edu>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu> <20110829122013.GA3597@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110829122013.GA3597@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stanislaw,

On 08/29/2011 07:20 AM, Stanislaw Gruszka wrote:
> On Sun, Aug 28, 2011 at 08:26:16AM -0500, Greg Dietsche wrote:
>    
>> This message should be a debug message and not a warning. So
>> change it from IWL_WARN to IWL_DEBUG_HT.
>>      
> I'm currently doing massive iwlegacy driver cleanup. Would be easier
> for me to apply these patches on top of my changes instead of rebase
> my patches. I will queue these two patches and post them together with
> my pending patches.
>
>    
That sounds good to me. I have the 4065 card in my laptop and want to 
learn how it works. If you want someone to test your changes, I'm willing.

I have six other patches that are trivial in nature for the iwlegacy 
driver. One of those also applies to the iwlagn driver, so seven patches 
in total. They remove some null checks that aren't necessary and also 
cleanup a few unused variables. There are two patches in the set that 
I'm not 100% sure about. They remove null checks and I haven't been able 
to prove to myself that they are correct. However, if they aren't 
correct, then there are some null checks in other places that need to be 
added....

Anyway, I can hold off on these until you've done your cleanup and see 
what still applies, or if you have a tree someplace, I'd be happy to 
rebase them for you. I've been running them on my laptop for a few days 
now with no problems.

Thanks,
Greg
