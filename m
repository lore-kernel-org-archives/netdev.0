From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Mon, 08 Apr 2013 23:24:37 -0700
Message-ID: <1365488677.3887.117.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	  <3294227.D2rod7xgQB@sifl> <1365454501.3887.45.camel@edumazet-glaptop>
	  <6182509.cOVcY8B4g7@sifl> <1365479891.3887.99.camel@edumazet-glaptop>
	 <5163992F.30406@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, mvadkert@redhat.com,
	linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5163992F.30406@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-04-08 at 21:29 -0700, Casey Schaufler wrote:

> I don't understand what this hook does.

It documents that security modules might need to get an sk pointer from
an skb, especially for TCP SYNACK messages.

> Does it affect Smack (which uses NetLabel) as well?
> How can I find out?

If you ask the question, thats is probably because Smack is not
affected.

selinux uses netfilter hooks, not Smack. selinux could probably refine
the need to set skb->sk based on CONFIG_NETFILTER, but I leave that
for a future change.

Just try the patch, and add your 'Tested-by', that will be fine.

If you believe Smack has an issue, tell us why, and we'll add the
follow-up patch.



