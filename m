From: Guillaume Thouvenin <guillaume.thouvenin@bull.net>
Subject: Re: Netlink Connector / CBUS
Date: Tue, 05 Apr 2005 10:11:23 +0200
Message-ID: <1112688683.8456.10.camel@frecb000711.frec.bull.fr>
References: <Xine.LNX.4.44.0504050108260.9383-100000@thoron.boston.redhat.com>
	 <1112686480.28858.17.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, Netlink List <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@redhat.com>, rml@novell.com,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1112686480.28858.17.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-04-05 at 11:34 +0400, Evgeniy Polyakov wrote:
> On Tue, 2005-04-05 at 01:10 -0400, Herbert Xu wrote:
>
> >In fact to this day I still don't understand what problems this thing is
> >meant to solve.
> 
> Hmm, what else can I add to my words?
> May be checking the size of the code needed to broadcast kobject changes
> in kobject_uevent.c for example...
> Netlink socket allocation + skb handling against call to cn_netlink_send().

And It's the same for the fork connector. It allows to send a message to
a user space application when a fork occurs by adding only one line (two
with the #include) in the kernel/fork.c file. Thus, the netlink
connector is a very simple and fast mechanism when you need to send a
small amount of information from kernel space to user space.

Regards,
Guillaume
