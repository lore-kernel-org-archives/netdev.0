From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Thu, 17 Dec 2015 12:00:24 -0500 (EST)
Message-ID: <20151217.120024.1598833629356298916.davem@davemloft.net>
References: <CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
	<20151217084809.GC9239@gondor.apana.org.au>
	<CADvbK_df=Z1re2wPUF9JCXggBzRqF=Tgt86PXV0KqBcx3VeVNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, phil@nwl.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: lucien.xin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_df=Z1re2wPUF9JCXggBzRqF=Tgt86PXV0KqBcx3VeVNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 17 Dec 2015 17:00:35 +0800

> On Thu, Dec 17, 2015 at 4:48 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Thu, Dec 17, 2015 at 04:46:00PM +0800, Xin Long wrote:
>>>
>>> sorry for late test, but unfortunately, my case with rhashtalbe still
>>> return EBUSY.
>>> I added some debug code in rhashtable_insert_rehash(), and found:
>>> *future_tbl is null*
>>>
>>> fail:
>>>         /* Do not fail the insert if someone else did a rehash. */
>>>         if (likely(rcu_dereference_raw(tbl->future_tbl))) {
>>>                 printk("future_tbl is there\n");
>>>                 return 0;
>>>         } else {
>>>                 printk("future_tbl is null\n");
>>>         }
>>>
>>> any idea why ?
>>
>> That's presumably because you got a genuine double rehash.
>>
>> Until you post your code we can't really help you.
>>
> i wish i could , but my codes is a big patch for sctp, and this issue
> happens in a special stress test based on this patch.
> im trying to think how i can show you. :)

Simply post it.
