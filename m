From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Fri, 17 Apr 2015 10:42:16 -0700
Message-ID: <1429292536.7346.248.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
	 <20150414.143747.1155055158701231768.davem@davemloft.net>
	 <552F9986.30207@redhat.com>
	 <1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55313D4D.4050402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55313D4D.4050402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-04-17 at 19:05 +0200, Denys Vlasenko wrote:

> How do you expect one to find excessively large inlines,
> if not on allyesconfig build?

Tuning kernel sources based on allyesconfig build _size_ only is
terrible. We could build an interpreter based kernel and maybe reduce
its size by 50% who knows...

You are saying that all inline should be removed, since it is obvious
kernel size _will_ be smaller.

That is an ... interesting idea, but hardly related to net_generic().
