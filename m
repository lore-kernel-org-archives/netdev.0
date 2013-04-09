From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 09 Apr 2013 07:45:39 -0400
Message-ID: <11981980.GvpKvtscPm@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <1365479891.3887.99.camel@edumazet-glaptop> <5163992F.30406@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5163992F.30406@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, April 08, 2013 09:29:35 PM Casey Schaufler wrote:
> Does it affect Smack (which uses NetLabel) as well?

The short answer is "no".  Smack approaches the network access controls 
differently and as a result has hooks in different places that do slightly 
different things; the regression in the network stack only affects SELinux.

-- 
paul moore
security and virtualization @ redhat

