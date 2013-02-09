From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH 1/1] eventfd: implementation of =?UTF-8?Q?EFD=5FMASK?=  =?UTF-8?Q?=20flag?=
Date: Sat, 09 Feb 2013 13:04:27 +0100
Message-ID: <522eddabbd205305038fef897d283f26@webmail.moloch.sk>
References: <1360219292-19754-1-git-send-email-sustrik@250bpm.com>
 <20130207144433.527ef024.akpm@linux-foundation.org>
 <5114F2D8.5020300@250bpm.com> <20130208222107.GA4762@dcvr.yhbt.net>
 <5115B720.2080207@250bpm.com> <20130209035431.GA28448@dcvr.yhbt.net>
 <5115FC6A.8000603@250bpm.com> <20130209115149.GA15636@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130209115149.GA15636@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-02-09 12:51, Eric Wong wrote:

> Yes, your eventfd change is probably the best way if you want/need
> to only watch a subset of your sockets, especially if you want
> poll/select to be an option.

Yes, the poll/select thing is the important point.

I wouldn't care if the only problem was that I, as the protocol 
implementer, would have to implement some kind of workaround in my 
protocol library. The problem is that these convoluted semantics leak -- 
through the use of poll, select et al. -- to the end user.

 From my personal experience I can say that end users have pretty hard 
time using such complex workarounds instead of simply using a native 
file descriptor with standardised semantics.

Martin
