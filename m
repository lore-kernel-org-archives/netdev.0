From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or hrtimers crashing
Date: Tue, 2 Nov 2010 15:49:47 +0200
Message-ID: <201011021549.47466.nuclearcat@nuclearcat.com>
References: <20101028070550.GA7647@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Paul Mackerras <paulus@samba.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43237 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0KBNtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 09:49:24 -0400
In-Reply-To: <20101028070550.GA7647@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't try yet, but i enable more debugs and catch linked list corruption. 

Here is dumps from netconsole:
http://www.nuclearcat.com/ll.txt
http://www.nuclearcat.com/ll2.txt		

I have another PC, also fails to run 2.6.36, but netconsole don't give 
anything.
Both PC's have strange issue with clock drifting away too much (on 2.6.35 and 
maybe even before).


On Thursday 28 October 2010 10:05:50 Jarek Poplawski wrote:
> On 2010-10-25 11:22, Denys Fedoryshchenko wrote:
> > Hi
> > 
> > Here is what i got from netconsole
> > 
> >  [  259.238755] BUG: unable to handle kernel
> >  paging request
> >  at f8ba001c
> >  [  259.238953] IP:
> >  [<c0199ebe>] do_select+0x2cc/0x502
> 
> ...
> 
> > It is not easy to do full git bisect(it is semi-embedded distro), but i
> > can try reversing particular commits, if someone can give idea which
> > one, and can try debug patches.
> 
> Hi,
> Nothing concrete, but you might try reverting this one:
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.36.y.git;a=commi
> tdiff;h=15fd0cd9a2ad24a78fbee369dec8ca660979d57e
> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
