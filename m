From: Greg Banks <gnb@fastmail.fm>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 21:58:25 +1000
Message-ID: <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown> <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop> <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, NeilBrown <neilb@suse.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110729103634.GA12050@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Sent from my iPhone

On 29/07/2011, at 20:36, Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Jul 29, 2011 at 04:53:21PM +1000, Greg Banks wrote:
>>> Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node 
>>> ()) to
>>> see how this strategy already was adopted for ksoftirqd, kworker,
>>> migration, and pktgend kthreads.
>>
>> Ah, I see.  It's unfortunate that the kthread_create() API ends up
>> being passed a CPU number but that's only used to format the name
>> and not for sensible things :(
>
> kthread_create doesn't have a cpu argument - it has a printf-like  
> format
> string.
>

Sure, and a whole lot of the callsites are ("..._%d", cpu), hence the  
unfortune :(

Greg.
