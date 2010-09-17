From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH 1/2] atl1: fix resume
Date: Thu, 16 Sep 2010 21:47:20 -0700 (PDT)
Message-ID: <20100916.214720.223472810.davem@davemloft.net>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
	<1284665387-10289-2-git-send-email-kronos.it@gmail.com>
	<20100916211318.GA29619@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kronos.it@gmail.com, netdev@vger.kernel.org, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com,
	atl1-devel@lists.sourceforge.net, stable@kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59639
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818Ab0IQErB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 00:47:01 -0400
In-Reply-To: <20100916211318.GA29619@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Thu, 16 Sep 2010 14:13:18 -0700

> On Thu, Sep 16, 2010 at 09:29:46PM +0200, Luca Tettamanti wrote:
>> adapter->cmb.cmb is initialized when the device is opened and freed when
>> it's closed. Accessing it unconditionally during resume results either
>> in a crash (NULL pointer dereference, when the interface has not been
>> opened yet) or data corruption (when the interface has been used and
>> brought down adapter->cmb.cmb points to a deallocated memory area).
>> 
>> Cc: stable@kernel.org
>> ---
> 
> You do realize you need to sign-off on a patch you create, right?

Right.

Luca please formally resubmit these patches with a proper signoff
and all of the accumulated ACKs so far.
