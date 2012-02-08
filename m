From: Hillf Danton <dhillf@gmail.com>
Subject: Re: [PATCH 00/15] Swap-over-NBD without deadlocking V8
Date: Wed, 8 Feb 2012 20:51:11 +0800
Message-ID: <CAJd=RBDYMKRVSKVp3dAhTCtu_wNDyayCObVA7q6G=fbkKpmZUw@mail.gmail.com>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
	<CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
	<20120207132745.GH5938@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120207132745.GH5938@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 7, 2012 at 9:27 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Feb 07, 2012 at 08:45:18PM +0800, Hillf Danton wrote:
>> If it is feasible to bypass hang by tuning min_mem_kbytes,
>
> No. Increasing or descreasing min_free_kbytes changes the timing but it
> will still hang.
>
>> things may
>> become simpler if NICs are also tagged.
>
> That would mean making changes to every driver and they do not necessarily
> know what higher level protocol like TCP they are transmitting. How is
> that simpler? What is the benefit?
>
The benefit is to avoid allocating sock buffer in softirq by recycling,
then the changes in VM core maybe less.

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
