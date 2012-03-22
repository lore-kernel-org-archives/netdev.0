From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Thu, 22 Mar 2012 16:17:03 -0700
Message-ID: <1332458223.6521.14.camel@edumazet-glaptop>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
	 <1332374452.9433.15.camel@edumazet-glaptop>
	 <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
	 <1332458037.6521.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52045 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031470Ab2CVXRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:17:05 -0400
Received: by iagz16 with SMTP id z16so3759102iag.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 16:17:04 -0700 (PDT)
In-Reply-To: <1332458037.6521.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-22 at 16:13 -0700, Eric Dumazet wrote:

> A third possibility (reading the code) if you use non blocking IO, is to
> send() a message right after connect()
> 
> 

Or use the auto connect on sendto() more probably...

That combines the connect() and send() 
