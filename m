From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC/PATCH] Convert architecture dependent rtnetlink attribute
 to fixed sized ones
Date: Tue, 24 Aug 2004 15:44:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824154400.73d8f176.davem@redhat.com>
References: <20040824094952.GF21073@postel.suug.ch>
	<E1BzYMJ-000208-00@gondolin.me.apana.org.au>
	<20040824120442.GA21296@postel.suug.ch>
	<20040824103205.1ea9c999.davem@redhat.com>
	<20040824204704.GM21296@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040824204704.GM21296@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 22:47:04 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Below is a patch which fixes some of the obvious architecture
> dependent and easy to fix attributes. But there are dozens more of
> them such as the int in struct tcf_police.

'int' happens to be fine, since it is the same size on 32-bit vs.
64-bit systems.  The conversion to explicitly sized types is
a nice cleanup, thanks.
