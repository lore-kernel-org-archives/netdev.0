From: Miika Komu <miika@iki.fi>
Subject: Re: IPsec performance
Date: Mon, 2 May 2005 22:09:02 +0300 (EEST)
Message-ID: <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 May 2005, Miika Komu wrote:

> Hi folks,
>
> I compared TCP-over-NULL-ESP vs. plain-TCP throughput with "ttcp" tool and
> obtained the following results:
>
> Plain-TCP:	11 megabytes/s
> NULL-ESP:	2.5 megabytes/s
>
> Am I doing something wrong? I did the measurements by transferring a 100
> megabyte file using vanilla 2.6.7 kernel and IPv6. Seems like my
> results are inconsistent at least with measurements published by Linux
> Journal:
>
> http://www.linuxjournal.com/article/7840
>
> The main differences with the Linux Journal measurements are that I used a
> significantly larger filesize and IPv6. So, I tried to run the same with
> IPv4 and got similar results... any ideas?

I browsed the archives also and found this one:

http://oss.sgi.com/archives/netdev/2004-12/msg00801.html

Nothing has been done for this?

-- 
Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
