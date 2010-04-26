From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] bluetooth: handle l2cap_create_connless_pdu() errors
Date: Mon, 26 Apr 2010 11:12:59 -0700 (PDT)
Message-ID: <20100426.111259.112594696.davem@davemloft.net>
References: <20100422123347.GA5265@vigoh>
	<20100426113627.GS29093@bicker>
	<20100426150919.GA12813@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, marcel@holtmann.org,
	andrei.emeltchenko@nokia.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: gustavo@padovan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139Ab0DZSMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:12:54 -0400
In-Reply-To: <20100426150919.GA12813@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo F. Padovan" <gustavo@padovan.org>
Date: Mon, 26 Apr 2010 12:09:19 -0300

> Hi Dan,
> 
> * Dan Carpenter <error27@gmail.com> [2010-04-26 13:36:27 +0200]:
> 
>> l2cap_create_connless_pdu() can sometimes return ERR_PTR(-ENOMEM) or
>> ERR_PTR(-EFAULT).
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>> ---
>> In v2 I wrote the patch on top of Gustavo Padovon's devel tree

This is the kind of bug that could cause a crash if the path actually
executes.

Therefore it tires me that that submitter was told to regenerate this
patch against some devel tree that is -next bound, when in fact this
is the kind of fix that warrants inclusion right now into net-2.6

Marcel, please do whatever magic you need to so I can get this into
Linus's tree as I did the rest of the ERR_PTR() fixes from Dan already.
No reason to treat Bluetooth special and defer these fixes to -next.

Thanks.
