From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Thu, 3 Dec 2015 06:38:20 -0500
Message-ID: <20151203113820.GX15262@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <20151202065305.GB14008@secunet.com>
 <20151202120538.GJ23178@oracle.com>
 <20151203084508.GD14008@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151203084508.GD14008@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/03/15 09:45), Steffen Klassert wrote:
> pcrypt(echainiv(authenc(hmac(sha1-ssse3),cbc-aes-aesni)))
> 
> Result:
> 
> iperf -c 10.0.0.12 -t 60
> ------------------------------------------------------------
> Client connecting to 10.0.0.12, TCP port 5001
> TCP window size: 45.0 KByte (default)
> ------------------------------------------------------------
> [  3] local 192.168.0.12 port 39380 connected with 10.0.0.12 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-60.0 sec  32.8 GBytes  4.70 Gbits/sec
> 
> I provide more informatios as soon as the code is available.

that's pretty good compared to the baseline. 
I'd like to try out our patches, when they are ready.

I think you may get some more improvement if you manually pin the irq 
and iperf to specific cpus (at least that was my observation for transp 
mode) 

--Sowmini
