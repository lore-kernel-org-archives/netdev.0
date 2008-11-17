From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ematch: simpler tcf_em_unregister()
Date: Sun, 16 Nov 2008 23:02:06 -0800 (PST)
Message-ID: <20081116.230206.213449343.davem@davemloft.net>
References: <20081115225501.GA2189@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbYKQHCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:02:06 -0500
In-Reply-To: <20081115225501.GA2189@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 16 Nov 2008 01:55:01 +0300

> Simply delete ops from list and let list debugging do the job.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks good, none of the callers were checking the return
value anyways :)
