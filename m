From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ibmveth: Fix h_free_logical_lan error on pool resize
Date: Sat, 09 Jun 2007 18:26:01 -0400
Message-ID: <466B28F9.2090703@garzik.org>
References: <200706081905.l58J5J3U017418@d03av01.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35138 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616AbXFIW0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:26:04 -0400
In-Reply-To: <200706081905.l58J5J3U017418@d03av01.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> When attempting to activate additional rx buffer pools on an ibmveth interface that
> was not yet up, the error below was seen. The patch fixes this by only closing
> and opening the interface to activate the resize if the interface is already
> opened.

applied 1-2 to #upstream-fixes


