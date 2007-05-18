From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Fri, 18 May 2007 11:47:35 -0400
Message-ID: <464DCA97.3070405@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Milton Miller <miltonm@bga.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:36328
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504AbXERPqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 11:46:53 -0400
In-Reply-To: <464DC676.90504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> David Acker wrote:
>> David Acker wrote:
>>> Done.  Below is a patch against 2.6.22-rc1.  It combines removing the 
>>> s-bit patch and applying the patch I previously sent.
>>
>> Oops.  I missed one state in that patch.  Since the el-bit buffer will 
>> normally not complete due to a zero size, we need to check if the 
>> buffer with no data has the el-bit set.  Without this, you have to 
>> wait for the interrupt.  Sorry about that...this was in the code I 
>> tested on my embedded system but got lost in the regular kernel patch.
> 
> OK. Thanks.
> 
> If you don't mind I'm going to have some testing on this patch done for 
> a bit now (mostly x86 hardware of course) to see if there's no pitfalls 
> in it. It'll be a few days because of the weekend before I get back on it.
> 

Cool.  I will see if I can get some more tests running over the weekend on our PXA255 
platform.

-Ack
