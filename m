From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 5/5 v2] netfilter: Fix format string of nfnetlink_log
 proc file
Date: Fri, 10 Apr 2015 09:31:19 +0200
Message-ID: <55277C47.4080201@nod.at>
References: <1428616637-21690-1-git-send-email-richard@nod.at>	 <1428616637-21690-5-git-send-email-richard@nod.at> <1428619177.5413.15.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org
To: Joe Perches <joe@perches.com>, Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428619177.5413.15.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 10.04.2015 um 00:39 schrieb Joe Perches:
> On Thu, 2015-04-09 at 23:57 +0200, Richard Weinberger wrote:
>> The printed values are all of type unsigned integer, therefore use
>> %u instead of %d. Otherwise an user can face negative values.
> 
> Hey Richard.
> 
> Just to clarify, this patch is for net and not for net-next
> as net-next has removed the seq_printf return uses.
> 
> Are you going to submit an equivalent patch for net-next?

Hmm, you are right. It took me a few minutes to figure out what happened
because I did rebase my patches to net-next and fixed up 5/5 already.
Reading yesterday's bash history shows that I've used
git format-patch in a wrong way such that the comments from the old
branch were taken.

Thanks,
//richard
