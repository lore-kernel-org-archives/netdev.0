From: James Chapman <jchapman@katalix.com>
Subject: Re: L2TP support?
Date: Thu, 22 Mar 2007 20:13:40 +0000
Message-ID: <4602E374.4010802@katalix.com>
References: <4602AA25.6020001@katalix.com> <200703221833.33530.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37258 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbXCVUNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 16:13:43 -0400
In-Reply-To: <200703221833.33530.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

Ingo Oeser wrote:
> Hi James,
> 
> James Chapman schrieb:
>> Is there interest in adding L2TP support?
> 
> Yes, if there is also a user space part somewhere.

Yes there is. There's a pppd plugin which comes with the openl2tp 
project, http://sf.net/projects/openl2tp. OpenL2TP supports both LAC and 
LNS operation. A patch is also available to allow this driver to be used 
with another L2TP implementation, l2tpd.

>> I have a patch which could be submitted for review. The PPPoL2TP driver
>> presents a PPPoX socket to userspace pppd in the same way as the PPPoE
>> and PPPoATM drivers. The kernel handles all data traffic, while
>> userspace daemons do L2TP and PPP control message processing.
> 
> Like the pppoe-plugin for pppd? 

Yes. :) The plan is to submit the pppol2tp plugin for pppd for inclusion 
in the pppd distro after the kernel driver is integrated.

> Yes, please check your patch using the nice checklist in 
> Documentation/SubmitChecklist and do it in suitable chunks 
> according to Documentation/SubmittingPatches

Will do.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


