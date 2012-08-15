From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] sctp: network namespace support Part 2:
 per net tunables
Date: Tue, 14 Aug 2012 23:10:44 -0700 (PDT)
Message-ID: <20120814.231044.1298412631777662795.davem@davemloft.net>
References: <87mx27rig7.fsf@xmission.com>
	<87zk67q31q.fsf_-_@xmission.com>
	<87ipcud3ld.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jan.ariyasu@hp.com, jan.ariyasu@gmail.com, nhorman@tuxdriver.com,
	tgraf@infradead.org, xi.wang@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ipcud3ld.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 07 Aug 2012 10:17:02 -0700

> 
> Since I am motivated to get things done, and since there has been much
> grumbling about my patches not implementing tunables, I have added
> tunable support on top of my last patchset.
> 
> I have performed basic testing on the these patches and nothing
> appears amis.
> 
> The sm statemachine is a major tease as it has all of these association
> and endpoint pointers in the common set of function parameters that turn
> out to be NULL at the most inconvinient times.  So I added to the common
> parameter list a struct net pointer, that is never NULL. 

Now that I have the ACKs from Vlad, I'm applying all of your work,
thanks Eric.
