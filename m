From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/4] netfilter: Fix format string of nfnetlink_queue proc
 file
Date: Mon, 16 Mar 2015 14:11:13 +0100
Message-ID: <20150316131113.GA5744@salvia>
References: <1426246276-15839-1-git-send-email-richard@nod.at>
 <1426246276-15839-5-git-send-email-richard@nod.at>
 <20150313121539.GA14488@salvia>
 <5502E99A.2060901@nod.at>
 <20150313135329.GA6054@salvia>
 <5502F28F.9050601@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5502F28F.9050601@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 13, 2015 at 03:22:07PM +0100, Richard Weinberger wrote:
> Am 13.03.2015 um 14:53 schrieb Pablo Neira Ayuso:
> >> You mean statistics via netlink attributes? I can add that!
> > 
> > Add a new NFQNL_CFG_CMD_STATS command to request the statistics. If
> > NLM_F_DUMP is set, then we'll basically provide the full list of
> > instances. Otherwise, in case you want to retrieve stats for a
> > specific netlink socket, you can use the netlink portID as index.
> > And you'll have to add attributes for this new command, yes.
> 
> This was my plan. Thanks for the pointer!

It would be great if you can contribute this new interface.

> >> But I think we should also fix the format string of the proc file
> >> as the fix is easy and non-intrusive.
> > 
> > Unfortunately we don't know how many people are relying on that
> > output, I prefer to remain conservative and provide a proper netlink
> > interface for this.
> 
> I understand your concerns but an application which is able to parse positive
> and negative numbers can also parse pure positives.
> Just made a small test application, glibc's %d in sscanf() can also deal with UINT_MAX.
> And I don't expect that applications to check whether the returned values from
> /proc/net/netfilter/nfnetlink_queue are between INT_MIN and INT_MAX.
> 
> That said, I'd have assumed that an user would report negative values as plain kernel bug.

Makes sense, please fix net/netfilter/nfnetlink_log.c too.

Thanks.
