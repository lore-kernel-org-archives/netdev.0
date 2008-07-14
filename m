From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 26-rc9-mmotm lockdep warning initializing loopback interface
Date: Mon, 14 Jul 2008 06:09:33 +0000
Message-ID: <20080714060933.GA4034@ff.dom.local>
References: <20080713210755.ed9257aa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexander Beregalov <a.beregalov@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756415AbYGNGEv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080713210755.ed9257aa.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14-07-2008 06:07, Andrew Morton wrote:
> On Sun, 13 Jul 2008 06:00:03 -0400 Valdis.Kletnieks@vt.edu wrote:
...
>> Found this in the dmesg:
>>
>> [    0.418581] system 00:0b: iomem range 0xfed00000-0xfed003ff has been reserved
>> [    0.421109]
>> [    0.421110] =============================================
>> [    0.421123] [ INFO: possible recursive locking detected ]
>> [    0.421132] 2.6.26-rc9-mm1 #2
>> [    0.421138] ---------------------------------------------
>> [    0.421147] swapper/1 is trying to acquire lock:
>> [    0.421154]  (&queue->lock){-...}, at: [<ffffffff804b81d5>] qdisc_lock_tree+0x27/0x2c
>> [    0.421176]
>> [    0.421177] but task is already holding lock:
>> [    0.421186]  (&queue->lock){-...}, at: [<ffffffff804b81cd>] qdisc_lock_tree+0x1f/0x2c
...
> (otoh, many of these problems are also in linux-next.  Who's testing
> that?  Hopefully it's a weekend*summer thing.)

http://permalink.gmane.org/gmane.linux.kernel.next/1514

Jarek P.

PS: it's only about lockdep annotation, and could be fixed with
other way finally.
