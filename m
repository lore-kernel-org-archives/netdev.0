From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Mon, 3 Sep 2007 11:12:29 +0200
Message-ID: <20070903091228.GB1899@ff.dom.local>
References: <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local> <46D8265B.6000405@bigtelecom.ru> <46D82AEC.5010404@bigtelecom.ru> <20070903073059.GA1899@ff.dom.local> <46DBC059.5020405@bigtelecom.ru> <46DBC66B.1000003@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48900 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750874AbXICJK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 05:10:58 -0400
Content-Disposition: inline
In-Reply-To: <46DBC66B.1000003@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 03, 2007 at 12:31:39PM +0400, Badalian Vyacheslav wrote:
> May you also see that i need change to fix this:
> 
> qdisc handle can >= 10 000
> 
> i have more then 10 000 qdiscs =(
> 

As far as I know qdisc handle is hex, so you can have e.g.:
handle 999a (or a999 too). But, does it mean your kernel has
any changes around this? If so, please, describe them all (or
send your patch).

I've read your bugzilla log with: "2. HTB levels wrong calculate!",
but can't check this now: could you add there what are these levels
you can see after: tc -d class show dev eth0 ?

Jarek P.
