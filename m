From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix secure tcp sequence number generation
Date: Sun, 3 Oct 2004 15:00:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003150052.4dba0c60.davem@redhat.com>
References: <415EEF0E.3080808@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <415EEF0E.3080808@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Oct 2004 20:10:22 +0200
Manfred Spraul <manfred@colorfullife.com> wrote:

> Ted's recent random.c update broke the periodic rekeying:
> schedule_work() doesn't provide synchronization. Additionally the first
> syn values after boot are generated with secret 0 - not good.

Are you referring to his changes done back in August or some
other change?  August is the last time I see that Ted made
a change to drivers/char/random.c
