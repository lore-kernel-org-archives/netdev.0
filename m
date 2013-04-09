From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 9 Apr 2013 17:38:07 +1000 (EST)
Message-ID: <alpine.LRH.2.02.1304091737310.13097@tundra.namei.org>
References: <20130408154519.18177.57709.stgit@localhost>  <3294227.D2rod7xgQB@sifl> <1365454501.3887.45.camel@edumazet-glaptop>  <6182509.cOVcY8B4g7@sifl> <1365479891.3887.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Moore <pmoore@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, mvadkert@redhat.com,
	linux-security-module@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365479891.3887.99.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 8 Apr 2013, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 90ba9b1986b5ac (tcp: tcp_make_synack() can use alloc_skb())
> broke certain SELinux/NetLabel configurations by no longer correctly
> assigning the sock to the outgoing SYNACK packet.
> 
> Cost of atomic operations on the LISTEN socket is quite big,
> and we would like it to happen only if really needed.
> 
> This patch introduces a new security_ops->skb_owned_by() method,
> that is a void operation unless selinux is active.
> 
> Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> Diagnosed-by: Paul Moore <pmoore@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-security-module@vger.kernel.org

Acked-by: James Morris <james.l.morris@oracle.com>


-- 
James Morris
<jmorris@namei.org>
