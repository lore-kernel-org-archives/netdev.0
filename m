From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 00/10] l2tp: misc fixes and add L2TPv3 IP encap over IPv6
Date: Mon, 23 Apr 2012 10:21:23 +0100
Message-ID: <4F951F13.9060301@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com> <20120422.002933.177233922611577116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34993 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907Ab2DWJV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 05:21:26 -0400
In-Reply-To: <20120422.002933.177233922611577116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/12 05:29, David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Fri, 20 Apr 2012 10:02:43 +0100
> 
>> This patch series includes several L2TP fixes / cleanups and adds
>> L2TPv3 IP encapsulation support for IPv6.
>>
>> Patches 4-10 depend on Benjamin LaHaise's L2TP UDP IPv6 patches which
>> have already been submitted for review. Patches 1-3 are not IPv6
>> related so can be reviewed / applied now.
> 
> They aren't in review state, they're in "changed requested" state
> because they are obviously broken and need changes since you hit
> all of those checksum problems on loopback when you tested it.
> 
> Never submit patch sets against another patch series that is going
> to have to go through changes before it goes into the tree.
> 
> I'm dropping this entire set, resubmit after Ben fixes the checksum
> problems and does a new submission.

Ok.

Ben, if I can help with the loopback checksum issue, please let me know.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
