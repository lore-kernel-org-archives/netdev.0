From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Fri, 19 Dec 2008 10:40:16 +0100
Message-ID: <494B6C00.2090603@computer.org>
References: <1229638581.3726.546.camel@calx>	<E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au>	<20081218224905.2bc81664@lxorguk.ukuu.org.uk>	<20081218230253.GA1855@gondor.apana.org.au> <20081218231407.4096a64e@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:56569 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbYLSJpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 04:45:15 -0500
Received: from [192.168.1.4] (athloroad.xperim.be [192.168.1.4])
	(authenticated bits=0)
	by via.xperim.be (8.14.1/8.14.1/Debian-8ubuntu1) with ESMTP id mBJ9eI79008711
	for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 10:40:19 +0100
In-Reply-To: <20081218231407.4096a64e@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>> $ grep fire drivers/char/lp.c
>>                         printk(KERN_INFO "lp%d on fire\n", minor);
> 
> Interesting. It got changed and then the change got lost between 2.2 and
> 2.4 somewhere. It was changed to report
> 
> "lp0 reported invalid error status (on fire, eh?)"
> 
> and it looks like that needs re-fixing.

/usr/src/linux# fgrep -r " on fire" *
arch/i386/kernel/cpu/mcheck/p5.c:               printk(KERN_EMERG 
"CPU#%d: Possible thermal failure (CPU on fire ?).\n", smp_processor_id());
drivers/macintosh/therm_windtunnel.c:   {  1, 0xfffff, 1 }      /* on 
fire */
drivers/char/lp.c:                      printk(KERN_INFO "lp%d on 
fire\n", minor);
drivers/net/eexpress.c:         "board on fire"));
include/asm-sparc64/solerrno.h:#define  SOL_ENETDOWN       127   /* Your 
subnet is on fire           */
include/asm-sparc/solerrno.h:#define    SOL_ENETDOWN       127   /* Your 
subnet is on fire           */

