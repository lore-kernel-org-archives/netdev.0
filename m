From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 19:48:39 +0300
Message-ID: <200808051948.40200.denys@visp.net.lb>
References: <20080805110453.GA6541@ff.dom.local> <200808051602.08047.denys@visp.net.lb> <20080805164103.GB2526@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:53244 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761007AbYHEQtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 12:49:25 -0400
In-Reply-To: <20080805164103.GB2526@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 August 2008, Jarek Poplawski wrote:
> >
> > I can prepare provide details with graphs to private email and reasons
> > why i do that. With TBF i think i cannot use flow classifier, if i am not
> > wrong, i must attach classful disciplines. I tried to attach just pfifo -
> > and i fail.
>
> If such config works for you then why bother? I've some doubts, but
> not enough to study some graphics ;)
>
TFB just make linear fifo, if user put downloading large file, and he have 
limit 256Kbit/s - his bandwidth and other apps will suffer.

If i put flow, SFQ or like i show rules - it will balance each flow to small 
fifo, and provide fair bandwidth to each flow. Flow with huge load just will 
have packets dropped more :-)
Means even if customer uses 256Kbit/s flat - his browsing still amazing 
fast... (it is checked).
