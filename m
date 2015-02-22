From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: initialize all rhashtable walker members
Date: Sun, 22 Feb 2015 16:29:41 -0500 (EST)
Message-ID: <20150222.162941.780862111589113271.davem@davemloft.net>
References: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com>
	<20150222.155838.307897095859530348.davem@davemloft.net>
	<54EA49E5.8040206@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54EA49E5.8040206@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sun, 22 Feb 2015 16:28:05 -0500

> On 02/22/2015 03:58 PM, David Miller wrote:
>> From: Sasha Levin <sasha.levin@oracle.com>
>> Date: Sat, 21 Feb 2015 15:55:11 -0500
>> 
>>> Commit "rhashtable: Introduce rhashtable_walk_*" forgot to initialize the
>>> members of struct rhashtable_walker after allocating it, which caused
>>> an undefined value for 'resize' which is used later on.
>>>
>>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> 
>> Commits should be referred to by SHA1 ID as well as the commit
>> header text (in parenthesis and double quotes).
> 
> It wasn't (isn't?) in Linus' tree yet, so I didn't want to refer to
> it by a SHA1 ID which would change.

Commit IDs in my tree _NEVER_ change.
