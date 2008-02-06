From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/14] replace __inline__ by inline in net code
Date: Wed, 06 Feb 2008 03:29:29 -0800 (PST)
Message-ID: <20080206.032929.129642913.davem@davemloft.net>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753798AbYBFL27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 06:28:59 -0500
In-Reply-To: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 06 Feb 2008 10:14:05 +0100

> The following patchset replaces all occurences of __inline__
> by inline and make some minor coding style fixes.
> 
> It touches:
>   . net/* files
>   . include/net/* files
>   . include/linux/* files (only the ones related to the network)
> 
> The patchset touches a lot of files and that can probably increase
> the patch conflict probability, but I have this patchset since a 
> few days, I didn't noticed any problem when updating net-2.6 and I
> hope that will be still the case.
> IMHO, it is the right moment to send this patch out, since net-2.6.25
> is closed and net-2.6.26 is not yet opened.

You have a point, but you also don't.

This makes debugging much harder since they not only have to go
through the real changes, they also have to go through transformations
like this one.

I'd much rather queue this up into net-2.6.26 when I open that up and
deal with whatever rejects.  For trivial transformations like this I
can resolve the rejects with my eyes closed. :-)

