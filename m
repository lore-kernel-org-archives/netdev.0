From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] [patch 0/6] [Network namespace] introduction
Date: Wed, 21 Jun 2006 00:45:40 +0200
Message-ID: <44987A94.3000705@fr.ibm.com>
References: <20060609210202.215291000@localhost.localdomain> <20060618184734.GB27946@ftp.linux.org.uk> <449866E7.4050508@fr.ibm.com> <20060620212511.GW27946@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:8429 "EHLO
	mtagate6.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751377AbWFTWpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:45:50 -0400
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20060620212511.GW27946@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> On Tue, Jun 20, 2006 at 11:21:43PM +0200, Daniel Lezcano wrote:
> 
>>Al Viro wrote:
>>
>>>On Fri, Jun 09, 2006 at 11:02:02PM +0200, dlezcano@fr.ibm.com wrote:
>>>- renaming an interface in one "namespace" affects everyone.
>>
>>Exact. If we ensure the interface can't be renamed if used in different 
>>namespace, is it really a problem ?
> 
> 
> You _still_ have a single namespace; look in /sys/class/net and you'll see.

Yes, that's right. The network devices namespaces are not yet 
implemented. There are potentially some conflicts with /proc and sysfs 
but we will address them in a future.

BTW, do you have some ideas on how handle these conflicts ?


