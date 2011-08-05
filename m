From: Julian Anastasov <ja@ssi.bg>
Subject: Re: return of ip_rt_bug()
Date: Fri, 5 Aug 2011 10:56:56 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108051048160.1494@ja.ssi.bg>
References: <20110802170942.GA17164@redhat.com> <alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg> <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com> <alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg> <CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
 <CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Tom London <selinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41803 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881Ab1HEHwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 03:52:39 -0400
In-Reply-To: <CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 4 Aug 2011, Tom London wrote:

> So, my router is just giving my wired NIC different addresses....
> 
> More I can provide?

	Thanks! Can you check in dmesg or in another log
about the first IP address in such line:

printk(KERN_DEBUG "ip_rt_bug: %pI4 -> %pI4, %s\n"

	Is it now 192.168.2.6 ?

Regards

--
Julian Anastasov <ja@ssi.bg>
