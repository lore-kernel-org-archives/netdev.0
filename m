From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Wed, 18 Feb 2004 05:30:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218053042.370876c9.ak@suse.de>
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

> Any comments welcome.

Looks good to me.

One small optimization would be to quickly check the receive queue without taking the
receive queue lock. This would avoid the additional lock in many cases.

-Andi
