From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] rxrpc: Add bits for kernel services
Date: Fri, 20 Oct 2017 08:43:08 +0100 (WEST)
Message-ID: <20171020.084308.2182191337868415716.davem@davemloft.net>
References: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 18 Oct 2017 12:55:50 +0100

> 
> Here are some patches that add a few things for kernel services to use:
> 
>  (1) Allow service upgrade to be requested and allow the resultant actual
>      service ID to be obtained.
> 
>  (2) Allow the RTT time of a call to be obtained.
> 
>  (3) Allow a kernel service to find out if a call is still alive on a
>      server between transmitting a request and getting the reply.
> 
>  (4) Allow data transmission to ignore signals if transmission progress is
>      being made in reasonable time.  This is also usable by userspace by
>      passing MSG_WAITALL to sendmsg()[*].
> 
> [*] I'm not sure this is the right interface for this or whether a sockopt
>     should be used instead.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-next
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-next-20171018

Pulled, thanks David.
