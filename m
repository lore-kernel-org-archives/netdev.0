From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem about Setting TCP Congestion Window to a Small Constant
Date: Sat, 22 Nov 2014 09:50:18 -0800
Message-ID: <1416678618.20938.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <a7b958c622a1f1ebed77d4ce44109ceb.squirrel@webmail.cs.utexas.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wc8348@cs.utexas.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:57262 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaKVRuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 12:50:21 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so1248450igi.6
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 09:50:20 -0800 (PST)
In-Reply-To: <a7b958c622a1f1ebed77d4ce44109ceb.squirrel@webmail.cs.utexas.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-11-22 at 10:29 -0600, wc8348@cs.utexas.edu wrote:
> Hi all,
>      My name is Wenzhi Cui, a graduate student working on TCP congestion
> control in Linux Kernel. I have a problem about congestion control in
> linux kernel.
> 
>      Recently I am playing with TCP Congestion Control Protocol by setting
> the congestion window size to a constant, say 1, and measure the TCP
> flow throughput to see the relationship between cwnd size and
> transmission rate (on a stable environment).
> 
>      The problem is, when I am setting the snd_cwnd to 1, the real
> transmission rate is around 25MBps. However, since I am testing TCP
> on our department network with 1Gbps (which is 125MBps) bandwidth and
> 300 micro seconds Round trip time (measured by analyzing tcpdump
> trace). So the theoretical sending rate should be
> CWND * MSS / RTT = 1 * 1460 Byte / 300 us = around 5 MBps
> which is far less than the observed 25 MBps bandwidth. I have taken a look
> at tcp_cong.c, tcp_input output.c, etc. but I still cannot find the
> problem.
> 
>      Can somebody help me figure out what is missing, maybe what may
> affect the real TCP transmission other than CWND or what will happen
> when CWND is set to a very small constant?

You probably did something wrong ?

tcpdump will probably show that your cwnd must be bigger than 1.
(or rtt is way smaller than 300 usec, which sounds quite big to me)
