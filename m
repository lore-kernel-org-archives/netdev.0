From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] Re: Fw: Stack sends SYN/ACKs even though accept
 queue is full
Date: Sun, 2 May 2004 22:17:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040502221705.4e7adef2.davem@redhat.com>
References: <4092EAD7.5080207@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, jan@ixiacom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <4092EAD7.5080207@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2004 17:09:59 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Normally, I think the expected behaviour was that connections
> would be short-lived. This is a reasonable expectation for most
> web-servers etc.

I don't know how relevant the "lifespan" of a connection is in
this case.

Servers tend to sip from the accept queue in a seperate thread
or approximate such behavior.  Therefore we have two time-frames,
the incoming connection acceptq one and the one that actually
deals with the established state data transation.  You're talking
about the latter, and the behavior in question is about the
former.

I really haven't seen a convincing argument yet to change the behavior
here, I think it's sane but I'm ready to be convinced otherwise :-)
