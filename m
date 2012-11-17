From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Sat, 17 Nov 2012 12:39:21 +0800
Message-ID: <50A714F9.4040206@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>	 <1353059821.3499.190.camel@zakaz.uk.xensource.com>	 <50A6255C.10108@oracle.com> <1353066382.3499.227.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37982 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab2KQEjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 23:39:37 -0500
In-Reply-To: <1353066382.3499.227.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 19:46, Ian Campbell wrote:
>
> It seems like having netfront simply allocate itself a pool of grant
> references which it reuses would give equivalent benefits whilst being a
> smaller patch, with no protocol change and avoiding double copying. In
> fact by avoiding the double copy I'd expect it to be even better.
>
>   

OK, I can try this implementation.
And I'd better to compare the performance between double copy and this 
implementation to see how much grant lock affects grant copy too.

> I think you need to measure both dom0->domU and domU->dom0 to get the
> full picture since AIUI netperf sends the bulk data in only one
> direction with just ACKs coming back the other way.
>   
Yes.
My environment does not meet requirement of more VMs, I would do more 
thorough test after Konrad setups the environment.

Thanks
Annie
