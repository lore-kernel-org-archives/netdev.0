From: linux lover <linux_lover2004@yahoo.com>
Subject: Re: how ip header added in ip_bulid_xmit function?
Date: Tue, 18 May 2004 23:20:44 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040519062044.15651.qmail@web90107.mail.scd.yahoo.com>
References: <40AA1C54.2090201@med.ge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxnet <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Manu Garg <manu.garg@med.ge.com>
In-Reply-To: <40AA1C54.2090201@med.ge.com>
List-Id: netdev.vger.kernel.org



hello,

> A packet comes from TCP layer to IP layer through
> function call 
> tp->af_specific->queue_xmit() (in
> tcp_output.c:tcp_transmit_skb() ). For 
> IP this function is nothing but ip_queue_xmit()
> defined in ip_output.c.
> 
   then why ip_build_xmit and ip_build_xmit_slow used?
i think in case of ICMP packet control in icmp.c
alwayes goes to ip_build_xmit?


regards,
linux_lover


	
		
__________________________________
Do you Yahoo!?
SBC Yahoo! - Internet access at a great low price.
http://promo.yahoo.com/sbc/
