From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC]: e1000: allow VLAN devices to use TSO and CSUM offload
Date: Sat, 11 Oct 2008 16:35:50 +0200
Message-ID: <48F0B9C6.3030905@trash.net>
References: <487DC7DB.70401@trash.net> <48EF690F.5070105@trash.net> <36D9DB17C6DE9E40B059440DB8D95F5206672441@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbYJKOfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 10:35:54 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5206672441@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
>> These parts should all work (at least as advertised in the software
>> reference manual available at
>>
> http://superb-east.dl.sourceforge.net/sourceforge/e1000/OpenSDM_8254x-37
> .pdf)
>> with the exception of 82544 GC/EI
>>
>> So as it stands your patch will not work on some hardware.  Also,
>> would we need to hook the ethtool methods such that if a user
>> disables TSO it will disable vlan_features(TSO) as well?  
> 
> Oh, and the 82542 and 82543 based parts don't do this either, they
> aren't covered by the manual above.

Thanks for the pointer (and for pushing the patch already).
