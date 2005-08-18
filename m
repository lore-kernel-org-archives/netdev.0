From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is
 now allocated only on demand.
Date: Thu, 18 Aug 2005 12:52:24 +1000
Message-ID: <4303F7E8.5030705@yahoo.com.au>
References: <20050810164655.GB4162@linux.intel.com> <20050810.135306.79296985.davem@davemloft.net> <20050810211737.GA21581@linux.intel.com> <430391F1.9080900@cosmosbay.com> <20050817211829.GK27628@wotan.suse.de> <4303AEC4.3060901@cosmosbay.com> <20050817215357.GU3996@wotan.suse.de> <4303D90E.2030103@cosmosbay.com> <20050818010524.GW3996@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Benjamin LaHaise <bcrl@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932108AbVHRCww@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050818010524.GW3996@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

>
>I would just set the ra pointer to a single global structure if the allocation
>fails. Then you can avoid all the other checks. It will slow down
>things and trash some state, but not fail and nobody should expect good 
>performance after out of memory anyways. The only check still
>needed would be on freeing.
>
>

You don't want to always have bad performance though, so you
could attempt to allocate if either the pointer is null _or_ it
points to the global structure?


Send instant messages to your online friends http://au.messenger.yahoo.com 
