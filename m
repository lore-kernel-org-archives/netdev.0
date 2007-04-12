From: David Miller <davem@davemloft.net>
Subject: Re: Getting a network interface list from within the kernel
Date: Thu, 12 Apr 2007 13:59:51 -0700 (PDT)
Message-ID: <20070412.135951.38690236.davem@davemloft.net>
References: <2970.1176411110@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753672AbXDLU7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 16:59:50 -0400
In-Reply-To: <2970.1176411110@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 12 Apr 2007 21:51:50 +0100

> What's the best way of doing this, assuming it's possible at all?

Issue a RTM_GETLINK rtnetlink request, and parse the response.
