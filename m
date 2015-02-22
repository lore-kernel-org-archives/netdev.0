From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] rhashtable: initialize all rhashtable walker members
Date: Sun, 22 Feb 2015 16:28:05 -0500
Message-ID: <54EA49E5.8040206@oracle.com>
References: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com> <20150222.155838.307897095859530348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150222.155838.307897095859530348.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/22/2015 03:58 PM, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Sat, 21 Feb 2015 15:55:11 -0500
> 
>> Commit "rhashtable: Introduce rhashtable_walk_*" forgot to initialize the
>> members of struct rhashtable_walker after allocating it, which caused
>> an undefined value for 'resize' which is used later on.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Commits should be referred to by SHA1 ID as well as the commit
> header text (in parenthesis and double quotes).

It wasn't (isn't?) in Linus' tree yet, so I didn't want to refer to
it by a SHA1 ID which would change.

> Even better, refer to the commit using a "Fixes: " tag right before
> your signoff.

Ok, should I resend?


Thanks,
Sasha
