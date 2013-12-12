From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 11 Dec 2013 19:58:52 -0500 (EST)
Message-ID: <20131211.195852.780453472852893891.davem@davemloft.net>
References: <20131212111539.cff1b2efe934c5cd7abbb822@canb.auug.org.au>
	<20131211.193639.2058525533631918382.davem@davemloft.net>
	<20131212114959.b08ea67fe5624ed6fb392c52@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jasowang@redhat.com,
	wuzhy@linux.vnet.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131212114959.b08ea67fe5624ed6fb392c52@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 12 Dec 2013 11:49:59 +1100

> Hi Dave,
> 
> On Wed, 11 Dec 2013 19:36:39 -0500 (EST) David Miller <davem@davemloft.net> wrote:
>>
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Thu, 12 Dec 2013 11:15:39 +1100
>> 
>> > Today's linux-next merge of the net-next tree got a conflict in
>> > drivers/net/macvtap.c between commit ce232ce01d61 ("macvtap: signal
>> > truncated packets") from the net tree and commit 55ec8e25cd97 ("macvtap:
>> > remove unused parameter in macvtap_do_read()") from the net-next tree.
>> > 
>> > I fixed it up (see below) and can carry the fix as necessary (no action
>> > is required).
>> 
>> The net-next commit in question was reverted last night.
> 
> Actually, the only relevant revert in the net-next tree I fetched this
> morning is commit de2aa4760b45 (Revert "macvtap: remove useless codes in
> macvtap_aio_read() and macvtap_recvmsg()") which reverts 41e4af69a598,
> not the commit mentioned above.  Unless you haven't pushed out the
> net-next tree with a later revert ...

Indeed, I was confusing those two commits.  Ok I should probably
revert that one too.

I'll go ahead and do that now, because it's the most straightforward
way to avoid this merge conflict.

Thanks!
