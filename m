From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET_NEXT RFC PATCH 1/3] ixgbe: add debugfs support
Date: Wed, 9 May 2012 16:10:29 -0700
Message-ID: <20120509161029.4a8f644b@nehalam.linuxnetplumber.net>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230940.31910.64408.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Catherine Sullivan <catherine.sullivan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43826 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757590Ab2EIXKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:10:33 -0400
In-Reply-To: <20120509230940.31910.64408.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 May 2012 16:09:40 -0700
Catherine Sullivan <catherine.sullivan@intel.com> wrote:

> This patch adds debugfs support to the ixgbe driver to give
> users the ability to access kernel information and to
> simulate kernel events.
> 
> The filesystem is set up in the following driver/PCI-instance
> hierarchy:
> <debugfs>
>    |-- ixgbe
> 	|-- PCI instance
> 	|	|-- attribute files
> 	|-- PCI instance
> 		|-- attribute files
> 
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>

This should be an optional configuration since it is meant for special
case usage. See SKY2_DEBUG
