From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Tue, 10 Feb 2004 00:42:47 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100033050.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <20040209121926.6f016ebf.davem@redhat.com> <4027FE27.9020102@candelatech.com>
 <20040209134551.3bd533a2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209134551.3bd533a2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, David S. Miller wrote:

> The existing ipv4 proxy-arp code is saying (as I read it) to not delay the
> response if this is a unicast probe.  This is one of the behaviors that
> Julian is modifying slightly.

	It will work as before if we have valid target

> For everyone's edification, when looking at changes Julian is suggesting, realize
> that his interests lie in IPVS like applications, so consider the corner case
> situations that such setups might be interested in and you'll see clearly the
> impetus for all of his ARP change proposals :-)

	You are almost right, yes, partially for arp_announce,
but IPVS like apps need more things to solve this problem. As for
this proxy_arp work it is entirely unrelated :) Hey, I'm not using only 
IPVS, it does not take my time from long long time :) Long time ago
I played with proxy_arp and was wondering why it behaves in this way.
I'm ready to leave this idea if the changes become too complex.

Regards

--
Julian Anastasov <ja@ssi.bg>
