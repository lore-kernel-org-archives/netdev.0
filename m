From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: HTB vs HFSC, HTB is highly inaccurate
Date: Mon, 9 Mar 2009 10:18:00 +0200
Message-ID: <200903091018.00180.denys@visp.net.lb>
References: <20090309080700.GA4760@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38116 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbZCIISH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 04:18:07 -0400
In-Reply-To: <20090309080700.GA4760@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 March 2009 10:07:00 Jarek Poplawski wrote:
> I guess you should try with rates 40/16 or 30/26 here.
Seems i was blind. I forgot main HTB rule - always keep sum or childs rate 
less than parent. And i should not listen my boss, cause he dont know 
arithmetics. (i ask him about decision, how much for what :-D ).

I will try some experiments now.

But at same time HFSC worked fine.
File fixed.

>
> BTW, it doesn't matter here, but for various reasons it's better to
> add classes before filters pointing these classes.
>
> > HFSC http://www.nuclearcat.com/netdev/hfsc-script.txt
>
> This link doesn't work for me.
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


