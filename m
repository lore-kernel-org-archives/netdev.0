From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] pptp: avoid releasing the sock too early
Date: Tue, 15 Sep 2015 13:39:10 -0400
Message-ID: <55F857BE.6060201@oracle.com>
References: <1442245229-31099-1-git-send-email-sasha.levin@oracle.com> <1442249027.14284.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, ebiederm@xmission.com, davem@davemloft.net,
	simon@farnz.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442249027.14284.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2015 12:43 PM, Eric Dumazet wrote:
> Hmm, is the synchronize_rcu() in del_chan() still needed, and why it was
> not enough ?
> 
> I believe your patch might reduce the race window, but it is not clear
> it is the right fix.

You're right, I've missed the synchronize_rcu() originally. At this point
I'm certain that my patch is incorrect (so ignore it please), but I don't see
the cause of the bug either.

Let me think about it some more...


Thanks,
Sasha
