From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH - RFC] [1/2] 2.6 must-fix list - kernel error reporting
Date: Sat, 12 Jul 2003 22:34:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030712223449.550d822a.davem@redhat.com>
References: <20030711224142.557b5b5e.davem@redhat.com>
	<Mutt.LNX.4.44.0307131052420.2146-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jkenisto@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   akpm@osdl.org, jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
   rddunlap@osdl.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0307131052420.2146-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 11:17:35 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

> On Fri, 11 Jul 2003, David S. Miller wrote:
> 
> > Oops, turns out this doesn't work.  data_ready is never NULL, look at
> > how netlink_kernel_create() works.
> 
> It's ok: sk->data_ready is never null, but nlk_sk(sk)->data_ready will be 
> null unless an input function is provided there.
> 
> > Also, the broadcast case probably needs to be handled
> > too?
> 
> Netlink sockets created by netlink_kernel_create() do not subscribe to any 
> groups and are not broadcast to.

Oops, you're right on both counts, I brainfarted here.

I'll apply your original patch, thanks.
