From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/7] NetLabel: documentation
Date: Fri, 28 Jul 2006 14:52:48 -0400
Message-ID: <44CA5D00.4010405@hp.com>
References: <20060717155224.060020000@hp.com>	<20060717155821.600856000@hp.com> <20060728.005104.78711481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:18594 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1752060AbWG1SxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:53:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060728.005104.78711481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: paul.moore@hp.com
> Date: Mon, 17 Jul 2006 11:52:25 -0400
> 
> 
>>+CIPSOv4 Variables:
>>+
>>+cipso_cache_enable - BOOLEAN
> 
>  ...
> 
>>+cipso_cache_bucket_size - INTEGER
> 
>  ...
> 
>>+cipso_rbm_optfmt - BOOLEAN
> 
>  ...
> 
>>+cipso_rbm_structvalid - BOOLEAN
> 
>  ...
> 
> We need some more information for these entries.
> 
> First, list the default value these sysctls will have.
> This is consistent with other entries in this file.  If
> there is a compelling argument to support the default
> value, please mention it.
> 
> Second, cipso_cache_bucket_size is still opaque, there is
> nothing in the description with describes the units this
> value is specified in, nor in fact what it really controls.
> Does it say how deep the hash chains of the hash table are
> allowed to grow to?  Otherwise, what does it control and what
> are the consequences of using different values?
> 

Okay, I'll work on the doc so to try and take care of these issues.

-- 
paul moore
linux security @ hp
