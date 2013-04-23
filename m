From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: socket file descriptor a/m/c-timestamps broken in <= 3.8.8?
Date: Mon, 22 Apr 2013 17:37:36 -0700
Message-ID: <1366677456.16391.101.camel@edumazet-glaptop>
References: <5175CA2F.2030206@felixbecker.name>
	 <20130423003015.GA26858@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Felix Becker <mail@felixbecker.name>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130423003015.GA26858@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-23 at 00:30 +0000, Eric Wong wrote:
> Cc:-ing netdev (no comments of my own)
> 
> Felix Becker <mail@felixbecker.name> wrote:
> > Hi,
> > 
> > I tried to figure out how old my TCP connections are and took a look
> > at /proc/<pid>/fd/<socketfdnum> using 'ls -la' / 'stat'.
> > 

Thanks, but its not a network issue, /proc/pid/fd are part of another
subsystem.

In particular, a/m/c timestamps are volatile (not meaningfull), as you
can make them disappear by 
"echo 3 >/proc/sys/vm/drop_caches"

Next time you use "ls /proc/pid/fd/..." timestamps are created.
