From: Sharat Masetty <sharat_masetty@yahoo.com>
Subject: Question about more headroom in skb
Date: Mon, 10 May 2010 13:09:27 -0700 (PDT)
Message-ID: <682359.68270.qm@web112510.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n6-vm0.bullet.mail.gq1.yahoo.com ([98.137.26.79]:22683 "HELO
	n6-vm0.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756339Ab0EJUJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:09:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

For my project I need 3 words of headroom in the skb in the network driver level, to add a  custom header to the ethernet packet. I looked into the tcp code and figured out tcp uses sk->sk_prot->max_header for header allocation size. But I was not able to confirm that all other transport protocol use the same mechanism(?) For example in UDP/ICMP I was not able to figure out from the code where the allocation and header reservation happens(Any light here would be really helpful.)

I have also looked at an API in skbuff skb_pad() which does what I want(add either headroom or tailroom), but I want to avoid that for performance reasons(skb_pad does kmalloc and memcpy). I want to figure out a good way(may be tune some parameters) to allocate extra 3 words for any skbuff independant of the transport protocol being used. Any light here would be very much appreciated.

Thanks,
Sharat.


      

