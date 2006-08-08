From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: 2.6.18-rc3-mm2: bad e1000 device name
Date: Tue, 08 Aug 2006 08:26:53 -0700
Message-ID: <44D8AD3D.60402@linux.intel.com>
References: <44D78A48.7050707@goop.org> <20060808004011.ab3cd65f.akpm@osdl.org> <44D8484E.9050904@goop.org> <44D8AB08.3000006@linux.intel.com> <44D8ACFE.3060802@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:34894 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S964947AbWHHP0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 11:26:54 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <44D8ACFE.3060802@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Arjan van de Ven wrote:
>> Jeremy Fitzhardinge wrote:
>>> Andrew Morton wrote:
>>>> e1000 seems OK here.  Don't know, sorry.
>>>>   
>>>
>>> It's happening to all my ethernet-like devices: the Atheros wireless 
>>> comes up as a mess too.  It's different each time, so it looks like 
>>> random uninitialized crud.
>>>
>>
>> is this the binary atheros driver? then please try without that.. 
> 
> It happens regardless of whether the atheros driver is loaded (or has 
> ever been loaded).  But it also happens to the atheros driver, so it 
> isn't specific to the e1000.
> 

and you're also sure this is not your userspace using interface renaming...
(could be an initscripts bug for name-by-MAC ethernet device naming)
