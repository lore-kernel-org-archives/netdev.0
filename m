From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/6] qeth: avoid crash in case of layer mismatch for
 VSWITCH
Date: Sun, 04 Jan 2009 17:36:53 -0800 (PST)
Message-ID: <20090104.173653.42738205.davem@davemloft.net>
References: <20090102150139.830998000@de.ibm.com>
	<20090102150254.617580000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751130AbZAEBgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:36:49 -0500
In-Reply-To: <20090102150254.617580000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 02 Jan 2009 16:01:42 +0100

> For z/VM GuestLAN or VSWITCH devices the transport layer is
> configured in z/VM. The layer2 attribute of a participating Linux
> device has to match the z/VM definition. In case of a mismatch
> Linux currently crashes in qeth recovery due to a reference to the
> not yet existing net_device.
> Solution: add a check for existence of net_device and add a message
> pointing to the mismatch of layer definitions in Linux and z/VM.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
