From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Tue, 17 Feb 2004 22:17:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217221705.183d58a6.davem@redhat.com>
References: <20040217121726.GD8554@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040217121726.GD8554@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004 13:17:26 +0100
Olaf Kirch <okir@suse.de> wrote:

> I'm currently investigating a problem in udp recvmsg. In short, a test
> program selects on the socket, gets woken up as a packet arrives, but
> recvmsg return EAGAIN because the UDP checksum was wrong.

Thanks Olaf, I'm not ignoring your patch I just didn't get to it today.
