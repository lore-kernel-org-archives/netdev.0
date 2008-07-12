From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] netxen: put back driver xmit lock
Date: Sat, 12 Jul 2008 13:53:47 -0700 (PDT)
Message-ID: <20080712.135347.44219316.davem@davemloft.net>
References: <1215890720-29744-7-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752631AbYGLUxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2008 16:53:46 -0400
In-Reply-To: <1215890720-29744-7-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat, 12 Jul 2008 12:25:20 -0700

> There's already discussion about pushing dev xmit lock into 
> drivers.

This is on hold, and meanwhile there is zero reason for the
driver to not take advantage of the mid-layer's lock.

None whatsoever.

