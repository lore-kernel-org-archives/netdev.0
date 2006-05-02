From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 001/100] TCP congestion module: add TCP-LP supporting
 for 2.6.16
Date: Tue, 2 May 2006 10:16:07 -0700
Message-ID: <20060502101607.0cb06071@localhost.localdomain>
References: <3feffd230605010305o6e3b1511of1f75b17f2797e66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48082 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964903AbWEBRQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 13:16:10 -0400
To: "Wong Edison" <hswong3i@gmail.com>
In-Reply-To: <3feffd230605010305o6e3b1511of1f75b17f2797e66@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 May 2006 18:05:52 +0800
"Wong Edison" <hswong3i@gmail.com> wrote:

> TCP Low Priority is a distributed algorithm whose goal is to utilize only
> the excess network bandwidth as compared to the ``fair share`` of
> bandwidth as targeted by TCP. Available from:
>   http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
> 
> See http://www-ece.rice.edu/networks/TCP-LP/ for their implementation.
> Our group take the following changes from
> the original TCP-LP implementation:
>   o We use newReno in most core CA handling. Only add some checking
>     within cong_avoid.
>   o Error correcting in remote HZ, therefore remote HZ will be keeped
>     on checking and updating.
>   o Handling calculation of One-Way-Delay (OWD) within rtt_sample, sicne
>     OWD have a similar meaning as RTT. Also correct the buggy formular.
>   o Handle reaction for Early Congestion Indication (ECI) within
>     pkts_acked, as mentioned within pseudo code.
>   o OWD is handled in relative format, where local time stamp will in
>     tcp_time_stamp format.
> 
> Port from 2.4.19 to 2.6.16 as module by:
>   Wong Hoi Sing Edison <hswong3i@gmail.com>
>   Hung Hing Lun <hlhung3i@gmail.com>
> 
> Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>
> 

Is this all of it?  Your subject line says there are a 99 more pieces.
That seems huge.
