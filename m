From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI interrupt data
Date: Sat, 15 Feb 2003 09:34:02 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030215092908.E16812@shell.cyberus.ca>
References: <3E4DE95C.2050804@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3E4DE95C.2050804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 15 Feb 2003, Jeff Garzik wrote:

> bash-2.05b$ ./x.pl data.crumb
> 135 samples, 21578 avg
> bash-2.05b$ ./x.pl data.hum
> 130 samples, 11213 avg
>

Probably the first 5-10 samples as well as the last 5-10 amples to get
more accuracy.

This data looks fine, no? definetly the scsi device is skewing things
(you are writting data to disk for example).
- The 500Kpps from ttcp doesnt sound right; tcp will slow you down.
perhaps use ttcp to send udp packets to get a more interesting view.

cheers,
jamal
