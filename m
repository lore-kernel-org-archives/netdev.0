From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Annotate change of locking mechanism for np->opt
Date: Thu, 18 Feb 2016 09:08:27 +0100
Message-ID: <1455782907.648.6.camel@edumazet-ThinkPad-T530>
References: <1455754833-31567-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455754833-31567-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On mer., 2016-02-17 at 16:20 -0800, Benjamin Poirier wrote:
> follows up commit 45f6fad84cc3 ("ipv6: add complete rcu protection around
> np->opt") which added mixed rcu/refcount protection to np->opt.
> 
> Given the current implementation of rcu_pointer_handoff(), this has no
> effect at runtime.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---

LGTM

Acked-by: Eric Dumazet <edumazet@google.com>
