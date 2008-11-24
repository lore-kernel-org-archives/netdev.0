From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 1/1][RFC]Handle uevent per namespace
Date: Mon, 24 Nov 2008 16:55:10 +0100
Message-ID: <492ACE5E.9020601@fr.ibm.com>
References: <492A86FA.5080804@fr.ibm.com> <20081124153138.GA16742@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:57351 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbYKXPzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 10:55:19 -0500
In-Reply-To: <20081124153138.GA16742@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Mon, Nov 24, 2008 at 11:50:34AM +0100, Daniel Lezcano wrote:
> 
>> Subject: Handle uevent per namespace
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> At present when a network device is destroyed, inside a network
>> namespace, and this device has the same name as one network device
>> belonging to the initial network namespace (eg. eth0), the udev daemon
>> will disable the interface in the initial network namespace.
>>
>> IMHO, udev should not receive this event. The uevents should be per
>> namespace or at least do not send events when not for the initial
>> network namespace.
> 
> IMHO, network namespaces are a mess and not something that you should be
> doing at all :)
> 
>> The following patch is a RFC for making uevent namespace aware. I don't
>> know this part of the kernel code, so I am pretty sure t is not the 
>> right way to do that :) 
> 
> Like Kay said, please don't change the kobject core for this, try just
> filtering in the network core the events that you handle there.

Oh, why I didn't think about that :)
That will be a cleaner and a smaller patch.

Thanks.
   -- Daniel
