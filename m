From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.4.26-pre1: SCTP compile error
Date: Thu, 26 Feb 2004 22:49:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226224958.24eb29fb.davem@redhat.com>
References: <Pine.LNX.4.58L.0402251605360.5003@logos.cnet>
	<20040226212759.GV5499@fs.tum.de>
	<Pine.LNX.4.58.0402261533500.19577@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, marcelo.tosatti@cyclades.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402261533500.19577@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2004 15:53:58 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> I missed this warning as i don't have irda enabled in my config.
> A simple fix would be to rename the macro in sctp.h to
> SCTP_MSECS_TO_JIFFIES.

I've fixed this in my tree.

> > ipv6.c: In function `sctp_v6_xmit':
> > ipv6.c:189: request for member `in6_u' in something not a structure or union
> > ipv6.c:189: request for member `in6_u' in something not a structure or union
> 
> I am not seeing these errors with either gcc3.2.2 or gcc2.96. But, looking at the
> code, this definitely seems to be a problem. Not sure why the newer versions of
> gcc didn't catch them.

It's trying to use NIP6() on an object that is not a struct in6_addr.
I'll just comment this thing out for now.
