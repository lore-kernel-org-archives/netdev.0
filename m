From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4/2.6] ipvs: improve conn rehashing, other fixes
Date: Mon, 22 Mar 2004 13:26:19 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403221320210.2896-100000@l>
References: <20040321230703.408d2240.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040321230703.408d2240.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sun, 21 Mar 2004, David S. Miller wrote:

> These look find to me at first glance.
>
> Wensong, resend to me under seperate cover once you've
> reviewed.

	Dave, if it is not too late, can you skip the change for
ip_vs_ctl.c (ip_vs_updsvc-*.diff) that adds the missing svc lock, it
seems it is not needed as the lock protects only the service list.

> THanks.

Regards

--
Julian Anastasov <ja@ssi.bg>
