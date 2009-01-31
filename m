From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] igb: Fix DCA errors and do not use context
 index for 82576
Date: Sat, 31 Jan 2009 00:53:31 -0800 (PST)
Message-ID: <20090131.005331.157276289.davem@davemloft.net>
References: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbZAaIxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 03:53:34 -0500
In-Reply-To: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 30 Jan 2009 16:53:43 -0800

> 82576 was being incorrectly flagged as needing a context index.  It does not as
> each ring has it's own table of 2 contexts.
> 
> Driver was registering after registering the driver instead of the other way around.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
