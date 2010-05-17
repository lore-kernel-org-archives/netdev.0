From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/6] net/sysfs: Fix the bitrot in network device
 kobject namespace support
Date: Sun, 16 May 2010 22:07:07 -0700 (PDT)
Message-ID: <20100516.220707.193713760.davem@davemloft.net>
References: <m14oim2kcm.fsf@fess.ebiederm.org>
	<20100505220150.GA11595@us.ibm.com>
	<m1y6fj3yym.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: serue@us.ibm.com, gregkh@suse.de, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, bcrl@lhnet.ca,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1y6fj3yym.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 16 May 2010 21:59:45 -0700

> 
> I had a couple of stupid bugs in:
> netns: Teach network device kobjects which namespace they are in.
> 
> - I duplicated the Kconfig for the NET_NS
> - The build was broken when sysfs was not compiled in
> 
> The sysfs breakage is because after I moved the operations
> for the sysfs to the kobject layer, to make things cleaner
> I forgot to move the ifdefs.  Opps.
> 
> I'm not quite certain how I got introduced a second NET_NS Kconfig,
> but it was probably a 3 way merge somewhere along the way that
> did not notice that the NET_NS Kconfig option had mvoed and thout
> that was a bug.  It probably slipped in because it used to be the
> sysfs patches were the first patches in my network namespace patches.
> Some things just don't go like you would expect.
> 
> Neither of these bugs actually affect anything in the common case
> but they should be fixed.
> 
> Thanks to Serge for noticing they were present.
> 
> Reported-by: Serge E. Hallyn <serue@us.ibm.com>
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Acked-by: David S. Miller <davem@davemloft.net>
