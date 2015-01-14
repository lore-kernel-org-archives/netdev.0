From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [REMINDER] iproute2 ss: Some thoughts about additional info
 output layout
Date: Wed, 14 Jan 2015 16:57:52 +0200
Message-ID: <20150114145752.GA30671@angus-think.wlc.globallogic.com>
References: <20150108221240.GA23636@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vadim4j@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:61919 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbbANPIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:08:24 -0500
Received: by mail-la0-f44.google.com with SMTP id gd6so8638675lab.3
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 07:08:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150108221240.GA23636@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 12:12:40AM +0200, Vadim Kochan wrote:
> Hi,
> 
> I think that current output of ss utility visually looks little weird
> when additional info options were specified, so I feel that a lot of
> yours will say that it will break existing scripts of ss output parsing
> but I will try, so thats how I think ss output would looks better in
> case if additionally info options were specified (I am not sure how it
> would looks in the email) :
> 
> 
> u_str  ESTAB      0      0                                                   * 14875                                                             * 14876
> users:("terminator",pid=30585,fd=8),
>       ("terminator",pid=29450,fd=8),
>       ("firefox",pid=21863,fd=8),
>       ("terminator",pid=18927,fd=8),
>       ("terminator",pid=17955,fd=8),
>       ("terminator",pid=9620,fd=8),
>       ("terminator",pid=7894,fd=8),
>       ("terminator",pid=7245,fd=8),
>       ("terminator",pid=2542,fd=8),
>       ("qtile",pid=654,fd=8)
> skmem:(r0,rb212992,t0,tb212992,f0,w0,o0,bl0) <-> 
> 
> u_str  ESTAB      0      0                                                   * 7550221                                                           * 7550222      
> users:("terminator",pid=9620,fd=12)
> skmem:(r0,rb4194304,t0,tb4194304,f0,w0,o0,bl0) <-> 
> 
> udp    ESTAB      0      0                                           10.3.5.18:ipproto-58744                                           192.168.1.1:swipe        
> users:("firefox",pid=21863,fd=54) 
> uid:1000 ino:7328962 sk:ffff880212f77bc0 <->
> skmem:(r0,rb4194304,t0,tb4194304,f0,w0,o0,bl0)
> 
> udp    ESTAB      0      0                           fe80::6e88:14ff:feac:51e4:ipproto-33582                                     fd6b:a256:8c2e::1:swipe        
> users:("firefox",pid=21863,fd=62) 
> uid:1000 ino:7328974 sk:ffff880205a76e80 <->
> skmem:(r0,rb4194304,t0,tb4194304,f0,w0,o0,bl0)
> 
> tcp    ESTAB      0      0                                       192.168.1.198:57851                                               173.194.113.205:https        
> users:("firefox",pid=21863,fd=67) 
> uid:1000 ino:7601516 sk:ffff880102e94d00 <->
> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
> ts sack cubic
> wscale:7,11
> rto:253.333 rtt:50.609/18.209 ato:40
> mss:1448 cwnd:10
> send 2.3Mbps lastsnd:46636 lastrcv:46570 lastack:46593 pacing_rate 4.6Mbps rcv_rtt:73.333 rcv_space:42340
> 
> tcp    ESTAB      0      0                                       192.168.1.198:47385                                                74.125.143.104:https        
> users:("firefox",pid=21863,fd=63)
> uid:1000 ino:7602727 sk:ffff880007a1db00 <->
> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
> ts sack cubic wscale:7,11 rto:296.666 rtt:95.496/22.756 ato:40
> mss:1418 cwnd:10
> send 1.2Mbps lastsnd:58640 lastrcv:58550 lastack:58550 pacing_rate 2.4Mbps rcv_rtt:96.666 rcv_space:42340
> 
> Regards,
> Vadim Kochan

Jut reminder may be it was missed within a lots of emails.

Thanks,
