From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/3] sysctl: add proc_do_large_bitmap
Date: Mon, 12 Apr 2010 14:32:10 +0800
Message-ID: <4BC2BE6A.4030500@redhat.com>
References: <20100409101442.5051.99812.sendpatchset@localhost.localdomain> 	<20100409101503.5051.3805.sendpatchset@localhost.localdomain> <s2w412e6f7f1004090333g3b23eb94udb1e6cc3939a07e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>, ebiederm@xmission.com,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s2w412e6f7f1004090333g3b23eb94udb1e6cc3939a07e5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
> On Fri, Apr 9, 2010 at 6:11 PM, Amerigo Wang <amwang@redhat.com> wrote:
>> From: Octavian Purdila <opurdila@ixiacom.com>
>>
>> The new function can be used to read/write large bitmaps via /proc. A
>> comma separated range format is used for compact output and input
>> (e.g. 1,3-4,10-10).
>>
>> Writing into the file will first reset the bitmap then update it
>> based on the given input.
>>
> 
> We have bitmap_scnprintf() and bitmap_parse_user(), why invent a new suite?
> 
> 

Because they don't accept '-'.
