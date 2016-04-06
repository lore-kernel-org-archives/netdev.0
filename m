From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not
 needed
Date: Wed, 06 Apr 2016 14:23:16 -0400 (EDT)
Message-ID: <20160406.142316.1728426867290841888.davem@davemloft.net>
References: <CAHC9VhS6aJdPR6xTH2-ehikS5qvj6jFbZAUtzoBXp+WC9Ugi=Q@mail.gmail.com>
	<1459951424.5425.12.camel@redhat.com>
	<CAHC9VhQS+LfPbj0UuKFiVCW7LKthJmgOt08MvCiwKjTZZYstxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, linux-security-module@vger.kernel.org,
	james.l.morris@oracle.com, agruenba@redhat.com, sds@tycho.nsa.gov,
	fw@strlen.de, netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: paul@paul-moore.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAHC9VhQS+LfPbj0UuKFiVCW7LKthJmgOt08MvCiwKjTZZYstxA@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul@paul-moore.com>
Date: Wed, 6 Apr 2016 10:07:27 -0400

> "While marking the LSM hook structure doesn't directly affect the
> SELinux netfilter hooks, once we remove the ability to deregister the
> LSM hooks we will have no need to support deregistering netfilter
> hooks and I expect we will drop that functionality as well to help
> decrease the risk of tampering."

This is not a reasonable postiion.

The performance implications are non-trivial for using netfilter hooks
when they aren't actually needed.
