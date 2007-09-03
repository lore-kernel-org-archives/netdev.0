From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Mon, 03 Sep 2007 12:05:45 +0400
Message-ID: <46DBC059.5020405@bigtelecom.ru>
References: <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local> <46D8265B.6000405@bigtelecom.ru> <46D82AEC.5010404@bigtelecom.ru> <20070903073059.GA1899@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:46601 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbXICIFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 04:05:49 -0400
In-Reply-To: <20070903073059.GA1899@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Your errors trigger in rbtree, which does indexing for HTB, but since
> it's something quite rare I think there is a very small probability
> that it's caused by HTB class/level handling (but it's possible, too),
> but more probable (to me) these indexes are corrupted by something e.g.
> like accessing them without proper locking.
>
> Below I attach a patch for testing: it adds some lock debugging (plus
> one place: htb_put is locked). There is mainly checking of locks
> needed for writing to rbtree, but it doesn't check all readings yet,
> so there will be still something to check if this patch doesn't help
> to find anything.
>
> It should be applied to 2.6.23-rc4, but if you prefer 2.6.22.5 version
> let me know (BTW, I hope you let us know if you have to apply any
> other patches/changes to these kernels...).
>
>   
Ok... i was apply patch and see that its say... thanks...
Maybe you see bug 2 (wrong level calculation) and 3 (class not leaf but 
have qdisc) at
http://bugzilla.kernel.org/show_bug.cgi?id=8971
