From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] reference count cleanup continued -IPv6
Date: Wed, 31 Mar 2004 23:12:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331231215.054f8a9a.davem@redhat.com>
References: <406AE4AC.6020309@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <406AE4AC.6020309@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004 07:33:00 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Continuing the reference count clean up, this time
> in tcp_v6_rcv().  We should not be doing a sock_put()
> on a socket in TIMEWAIT state.
> 
> Applies to 2.6.4. Should apply to current bits as
> well.

Applied, thanks Nivedita.

I've also coded up a 2.4.x variant, but you can feel free to
do this for me in the future :-)
