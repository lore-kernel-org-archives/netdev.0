From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] trivial patch for if_indextoname()
Date: Wed, 26 May 2004 15:34:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5CD535A8.8AB4C183-ON88256EA0.007B7EC7-88256EA0.007BF878@us.ibm.com>
References: <20040526151751.73752ea2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040526151751.73752ea2.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Miller wrote on 05/26/2004 03:17:51 PM:

> How is the SIOCGIFNAME interface specified in this case?
> (ie. what does BSD do?)  I bet a bunch of stuff will
> break if we change this.

I don't know if it exists in a standard; I'll see if I can
figure out what BSD is doing. The glibc code for
if_indextoname() appears to do the same thing for Linux
as BSD, so if BSD doesn't return ENXIO, it'd be broken
for RFC3493 too. But remapping it in glibc is safer I
suppose.

                                        +-DLS
