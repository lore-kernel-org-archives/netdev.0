From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 02:12:58 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411190209090.8343-100000@thoron.boston.redhat.com>
References: <20041118230109.V2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
        Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041118230109.V2357@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Chris Wright wrote:

> > (Also now ignores any supplied address per 
> > http://www.opengroup.org/onlinepubs/009695399/functions/sendto.html)
> 
> Nitpick, but I missed where it said ignore the address.  And it seems
> counter intuitive to provide address, only to have it ignored and
> delivered elsewhere.

For sendto():
  "If the socket is connection-mode, dest_addr shall be ignored."

For sendmsg():
  "If the socket is connection-mode, the destination address in msghdr 
   shall be ignored."

I agree that it's counter intuitive (and surely an application bug), but
some feedback I've had suggests we follow the spec.


- James
-- 
James Morris
<jmorris@redhat.com>
