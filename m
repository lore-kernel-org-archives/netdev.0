From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/2] scm: Stop passing struct cred
Date: Fri, 05 Apr 2013 00:47:54 -0400 (EDT)
Message-ID: <20130405.004754.281478419999797757.davem@davemloft.net>
References: <87li8zhwkw.fsf_-_@xmission.com>
	<87d2ubhwiw.fsf_-_@xmission.com>
	<87li8zezzj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, dingtianhong@huawei.com,
	edumazet@google.com, luto@amacapital.net, ksrot@redhat.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87li8zezzj.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 03 Apr 2013 20:28:16 -0700

> 
> Now that uids and gids are completely encapsulated in kuid_t
> and kgid_t we no longer need to pass struct cred which allowed
> us to test both the uid and the user namespace for equality.
> 
> Passing struct cred potentially allows us to pass the entire group
> list as BSD does but I don't believe the cost of cache line misses
> justifies retaining code for a future potential application.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

I'll apply this to net-next once #1 and #2 propagate there.

Thanks!
