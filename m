From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Thu, 19 Feb 2004 08:07:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219080705.6dffcaaf.ak@suse.de>
References: <20040217121726.GD8554@suse.de>
	<20040217221705.183d58a6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040217221705.183d58a6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004 22:17:05 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 17 Feb 2004 13:17:26 +0100
> Olaf Kirch <okir@suse.de> wrote:
> 
> > I'm currently investigating a problem in udp recvmsg. In short, a test
> > program selects on the socket, gets woken up as a packet arrives, but
> > recvmsg return EAGAIN because the UDP checksum was wrong.
> 
> Thanks Olaf, I'm not ignoring your patch I just didn't get to it today.

BTW I think TCP could hit the same problem. But it did already csum-copy
in user context in 2.4 and nobody reported it.

-Andi
