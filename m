From: "David S. Miller" <davem@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 14:45:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209144557.64f288fe.davem@redhat.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	<20040209121926.6f016ebf.davem@redhat.com>
	<4027FE27.9020102@candelatech.com>
	<20040209134551.3bd533a2.davem@redhat.com>
	<Pine.LNX.4.58.0402100033050.1251@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100033050.1251@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 00:42:47 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> I'm ready to leave this idea if the changes become too complex.

I think it's not so much your changes as this huge ugly ARP receive
processing function.  It is a mockery of functional programming :-)

I even tried to split this damn thing up today into smaller chunks but
there is so much shared state (like 6 or 7 live variables that all of
the logic ends up referencing) that such efforts proved futile.

It's hard and time consuming to verify any patch to this code for
that reason.
