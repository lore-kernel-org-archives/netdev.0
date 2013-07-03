From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 03 Jul 2013 11:45:08 +0300
Message-ID: <51D3E494.50206@linux.intel.com>
References: <20130703174822.d06500db5cbd5191c39e3f08@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130703174822.d06500db5cbd5191c39e3f08@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 03/07/2013 10:48, Stephen Rothwell wrote:
> Hi all,
>
> After merging the final tree, today's linux-next build (powerpc
> allnoconfig) failed like this:
>
> fs/select.c: In function 'do_select':
> fs/select.c:408:2: error: implicit declaration of function 'll_start_time' [-Werror=implicit-function-declaration]
>    u64 ll_start = ll_start_time(ll_flag);
[..]
> Caused by commit 1bc2774d8664 ("net: convert lls to use time_in_range()")
> from the net-next tree.
>
> I cherry-picked the commit 419076f59fc5 ("net: lls fix build with
> allnoconfig") out of tomorrow's net-next tree.  (I am feeling generous
> and noticed that patch being applied :-))

Yes, my bad.
Thank you.

I knew lots of people could get this so I sent out a fix ASAP (at 6AM
my time).

If it's not too much trouble we should add:
Reported-by: kbuild test robot <fengguang.wu@intel.com>

-Eliezer
