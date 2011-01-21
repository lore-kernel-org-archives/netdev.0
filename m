From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: fix link attribute validation with
 IFLA_GROUP
Date: Thu, 20 Jan 2011 23:29:06 -0800 (PST)
Message-ID: <20110120.232906.199042341.davem@davemloft.net>
References: <4D3831FA.2010806@trash.net>
	<20110120160909.GC12415@cormyr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: ddvlad@rosedu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751040Ab1AUH2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:28:32 -0500
In-Reply-To: <20110120160909.GC12415@cormyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Dogaru <ddvlad@rosedu.org>
Date: Thu, 20 Jan 2011 18:09:10 +0200

> On Thu, Jan 20, 2011 at 02:00:42PM +0100, Patrick McHardy wrote:
>> Fix a few semantic problems with the new IFLA_GROUP attribute.
>> 
>> Vlad, could you please give this is a try to see whether it
>> still behaves as expected?
> 
>> commit e4b31d565a45e06ed2e51a005f5c00ff1d00725c
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Thu Jan 20 13:55:25 2011 +0100
>> 
>>     rtnetlink: fix link attribute validation with IFLA_GROUP
>>     
>>     rtnl_group_changelink() is invoked by rtnl_newlink() before the link
>>     attributes have been validated. Additionally the group changes are
>>     performed even if NLM_F_CREATE is specified and a new link is
>>     created, while more reasonable semantics would be to set the group
>>     value on the newly created link.
>>     
>>     Fix both problems by moving the rtnl_group_changelink() invocation
>>     down to the handling of non-existant links without NLM_F_CREATE()
>>     and add a dev_set_group() call to rtnl_create_link().
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Acked-by: Vlad Dogaru <ddvlad@rosedu.org>

Applied, thanks everyone.
