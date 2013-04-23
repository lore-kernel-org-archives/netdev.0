From: Felix Becker <mail@felixbecker.name>
Subject: Re: socket file descriptor a/m/c-timestamps broken in <= 3.8.8?
Date: Wed, 24 Apr 2013 00:53:01 +0200
Message-ID: <517710CD.3020205@felixbecker.name>
References: <5175CA2F.2030206@felixbecker.name>  <20130423003015.GA26858@dcvr.yhbt.net> <1366677456.16391.101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Wong <normalperson@yhbt.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366677456.16391.101.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

thank you for that info. Can you tell which mailing list the right one
for this issue is?

Felix

On 04/23/2013 02:37 AM, Eric Dumazet wrote:
> On Tue, 2013-04-23 at 00:30 +0000, Eric Wong wrote:
>> Cc:-ing netdev (no comments of my own)
>> 
>> Felix Becker <mail@felixbecker.name> wrote:
>>> Hi,
>>> 
>>> I tried to figure out how old my TCP connections are and took
>>> a look at /proc/<pid>/fd/<socketfdnum> using 'ls -la' /
>>> 'stat'.
>>> 
> 
> Thanks, but its not a network issue, /proc/pid/fd are part of 
> another subsystem.
> 
> In particular, a/m/c timestamps are volatile (not meaningfull), as 
> you can make them disappear by "echo 3 >/proc/sys/vm/drop_caches"
> 
> Next time you use "ls /proc/pid/fd/..." timestamps are created.
> 
> 
> 
> -- To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at http://www.tux.org/lkml/
> 
