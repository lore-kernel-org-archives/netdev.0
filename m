From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH - RFC] [1/2] 2.6 must-fix list - kernel error reporting
Date: Fri, 11 Jul 2003 22:09:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711220905.2ea9ebc5.davem@redhat.com>
References: <3F0DB9A5.23723BE1@us.ibm.com>
	<Mutt.LNX.4.44.0307120135120.21806-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jkenisto@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   akpm@osdl.org, jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
   rddunlap@osdl.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0307120135120.21806-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Jul 2003 01:37:44 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

> On Thu, 10 Jul 2003, Jim Keniston wrote:
> 
> > That begs the question: do we trust that nobody but the kernel will send
> > packets to a NETLINK_KERROR socket?  Ordinary users can't, but any root
> > application can.  Without kerror_netlink_rcv(), such packets don't get
> > dequeued.
> 
> Indeed, the kernel socket buffer fills up.
> 
> I think this needs to be addressed in the netlink code, per the patch 
> below.

Looks good, I'll apply this.
