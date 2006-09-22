From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Fw: [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 10:20:31 +0200
Message-ID: <20060922082031.GA6820@ff.dom.local>
References: <20060922080310.GA1012@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:28315 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932070AbWIVIQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 04:16:24 -0400
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060922080310.GA1012@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry linux-kernel - it should go to netdev.


On 22-09-2006 10:03, Jarek Poplawski wrote:
> On 22-09-2006 00:37, Andrew Morton wrote:
>> Methinks CONFIG_NETFILTER_XT_TARGET_CLASSIFY should depend upon
>> CONFIG_BRIDGE_NETFILTER.  Because brnf_deferred_hooks is defined in
>> net/bridge/br_netfilter.c and is referred to in net/netfilter/xt_physdev.c.
>>
>> Or something else ;)
> 
> From net/netfilter/Kconfig:
> 
> config NETFILTER_XT_MATCH_PHYSDEV
>         tristate '"physdev" match support'
>         depends on NETFILTER_XTABLES && BRIDGE_NETFILTER
> 
> so "properly" generated .config should be enough.
> 
> Jarek P.
> 
> PS: I've just checked and it compiles OK. 



