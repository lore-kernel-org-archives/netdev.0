From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check
 missing
Date: Sat, 5 Jun 2004 14:37:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605143714.729744f8.davem@redhat.com>
References: <20040605204334.GA1134@suse.de>
	<20040605140153.6c5945a0.davem@redhat.com>
	<20040605211701.GD1134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20040605211701.GD1134@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Jun 2004 23:17:01 +0200
Olaf Hering <olh@suse.de> wrote:

>  On Sat, Jun 05, David S. Miller wrote:
> 
> > I can't see a reason, can anyone else?  If there is no reason, the
> > right fix is simply to mask it out at the top level, for both
> > sendmsg and recvmsg.
> 
> I did it first this way, but the result was a long delay until the dhcp
> server replied, the patch sent earlier leads to a fast reply.
> 
>     err = sock_recvmsg(sock, &msg_sys, total_len, flags & ~MSG_CMSG_COMPAT);

See my other email, net/core/scm.c needs this bit set all the
way down into the implementations.
