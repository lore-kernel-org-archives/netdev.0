From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation
 Needed message
Date: Mon, 04 Jun 2007 13:38:41 +0800
Message-ID: <4663A561.7070300@cn.fujitsu.com>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au> <46638F2D.90608@cn.fujitsu.com> <20070604041406.GA28263@gondor.apana.org.au> <466395F1.7060003@cn.fujitsu.com> <20070604045506.GA28580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:58652 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbXFDFo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 01:44:57 -0400
In-Reply-To: <20070604045506.GA28580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I know, I misunderstand the iph->tot_len, the ICMP payload is not 
contained a valid ipv4 packet.
I do this under IPv6, it has no problem because IPv6 does not check 
this. ^_^

Thank you very much.
> But this is not the old_mtu field that we were talking about.  The
> old_mtu field comes from iph->tot_len which is the length of field
> in the *original* IP header.  We're certainly not allowed touch that
> field.
>
> Cheers,
>   


-- 

A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yjwei@cn.fujitsu.com 
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-858
COINS: 79955-858
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------

