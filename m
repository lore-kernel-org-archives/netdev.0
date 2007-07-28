From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: RFC/Progress update: e1000e pci-express -only e1000 driver
Date: Sat, 28 Jul 2007 11:18:17 -0700
Message-ID: <46AB8869.5050205@intel.com>
References: <46AA5FB8.9090600@intel.com> <p73sl78r5yu.fsf@bingen.suse.de> <46AB85FB.10102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59264 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbXG1SSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2007 14:18:33 -0400
In-Reply-To: <46AB85FB.10102@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Andi Kleen wrote:
>> "Kok, Auke" <auke-jan.h.kok@intel.com> writes:
>>
>>> * Removed all multi-queue code
>> Why? With David's new multi NAPI work it will finally make sense, won't it?
> 
> It will come back, most definitely.
> 
> Not speaking for Auke, but I'm pretty sure this falls under the category 
> of "start small and simple, get it into the tree rapidly."

on top of that it's trivial to add it back, is currently not even used (!) and 
just a remnant of earlier efforts.

PJ is working on getting a consistent multiqueue patch out and he will (once 
this driver is ready) write a proper patch to add it back after the driver gets 
merged.

Auke
