From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: 2.4.18 and out of window packets
Date: Wed, 15 May 2002 13:46:31 +0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020515134631.A624@castle.nmd.msu.ru>
References: <Pine.LNX.4.33.0205101521110.31570-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.33.0205101521110.31570-100000@blackhole.kfki.hu>; from "Jozsef Kadlecsik" on Tue, May 14, 2002 at 10:09:36AM
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2002 at 10:09:36AM +0200, Jozsef Kadlecsik wrote:
> 11:28:34.212520 x.x.x.x.33299 > 148.6.0.24.39413: S [tcp sum ok]
> 	4065695110:4065695110(0) win 5840
> 	<mss 1460,sackOK,timestamp 90809727 0,nop,wscale 4>
> 	(DF) (ttl 44, id 12537, len 60)
> 11:28:34.212696 148.6.0.24.39413 > x.x.x.x.33299: S [tcp sum ok]
> 	4249346209:4249346209(0) ack 4065695111 win 5792
> 	<mss 1460,sackOK,timestamp 326603 90809727,nop,wscale 0>
> 	(DF) (ttl 63, id 0, len 60)
> 11:28:34.266715 x.x.x.x.33299 > 148.6.0.24.39413: . [tcp sum ok]
> 	4065695111:4065695111(0) ack 4249346210 win 365
> 	<nop,nop,timestamp 90809732 326603>
> 	(DF) (ttl 44, id 12538, len 52)
> 11:28:34.267237 148.6.0.24.39413 > x.x.x.x.33299: .
> 	4249346210:4249347658(1448) ack 4065695111 win 5792
> 	<nop,nop,timestamp 326608 90809732>
> 	(DF) [tos 0x8]  (ttl 63, id 7026, len 1500)
> 
> The fourth packet seems to be truly out of window.

It is in window.
The window size is 365*2^4=5840, starting at 4249346210.
