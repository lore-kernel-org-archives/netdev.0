From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Fri, 13 Feb 2004 01:50:32 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402130138540.1149@u.domain.uli>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
 <20040209140853.69ab8bea.davem@redhat.com> <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
 <20040209151053.1f63937a.davem@redhat.com> <Pine.LNX.4.58.0402100251380.1251@u.domain.uli>
 <20040211201656.4e4f708e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040211201656.4e4f708e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 11 Feb 2004, David S. Miller wrote:

> But I want the docs for the sysctl to talk about this.  Something
> simple like:
>
> +	1 - Try to avoid local addresses that are not in the target's
> +	subnet for this interface as far as we know.  In some environments
> +	subnets may be active that this system is not aware of, thus this
> +	setting might cause problems in such cases.
>
> Tweak it however you wish, just get the idea/warning across.
>
> I'd also prefer if you at least lightly define what "best" source address
> means in the context of arp_announce==2.

	I hope I explained them using my non-native english :)
May be the info is not good enough and can be improved. This is
against latest bk (there will be no conflict with the recently added 
flag):

http://www.ssi.bg/~ja/arp_announce-2.6.2-4.diff

Regards

--
Julian Anastasov <ja@ssi.bg>
