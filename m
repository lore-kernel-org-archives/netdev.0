From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.18] e1000: fix initialization irqs
Date: Wed, 22 Nov 2006 12:51:19 -0800
Message-ID: <4564B847.80908@intel.com>
References: <200611221549.15765.dim@openvz.org> <45647884.9080607@intel.com> <200611221943.53963.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, akpm@osdl.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6404 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1756756AbWKVTya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 14:54:30 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200611221943.53963.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> On Wednesday 22 November 2006 19:19, Auke Kok wrote:
>> Now you're telling the NIC to send interrupts before we routed them I think.
>>
>> If we _up() before we even have an interrupt, even more bad things could happen.
>>
>> What is the reason you wrote this workaround?
> The reason is simple, we've got this oops due to misrouted interrupts, 
> misrouted_irq() function. This workaround helps us, please, advice how to  fix
> it or fix it yourself.

without knowing all the parameters that are involved, I cannot make an informed fix at 
all. I need to see the oops, a full dmesg dump, lspci -vv, and possibly more (preferably 
both before and after the OOPS).

If you can provide those then that would really help a lot, especially since the "fix" 
you provide introduces a great number of trap doors and other undetermined behaviour.

Cheers,

Auke
