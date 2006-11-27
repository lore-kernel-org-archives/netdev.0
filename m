From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging
 etc.
Date: Mon, 27 Nov 2006 11:39:58 +0100
Message-ID: <456AC07E.6000606@trash.net>
References: <20061127065614.GB1625@ff.dom.local> <456AB61B.3040205@trash.net> <20061127104140.GA2866@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61828 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1758013AbWK0KkA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 05:40:00 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061127104140.GA2866@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Mon, Nov 27, 2006 at 10:55:39AM +0100, Patrick McHardy wrote:
> 
>>Your patch looks good, but it conflicts with my patches.
> 
> 
> I know, but I wasn't sure which version this changes
> are needed for. If there will be something more to do,
> name the version, please. 

Just add it on top of them. They apply cleanly to the current
-git tree.

>>One thing I forgot to mention is that it should also have
>>a callback for deactivating classes when their childs
>>become empty. If you do that you can just call
>>disc_tree_decrement_qlen in graft/delete, which will take
>>care of the qlen decrement and class deactivation.
> 
>  
> If I understand correctly I should apply this to 
> the version after your patch (plus the missing cbq part
> of "endless loops"). I'll try.

Thanks.
