From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/net/ethernet/ibm/ehea/ehea_main.c: add
 alias entry for portN properties
Date: Mon, 16 Sep 2013 21:29:46 -0400 (EDT)
Message-ID: <20130916.212946.2006011829000966313.davem@davemloft.net>
References: <20130913.195857.1842211951469893139.davem@davemloft.net>
	<20130916205543.GA14221@oc0268524204.ibm.com>
	<20130916210141.GB14221@oc0268524204.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	ohering@suse.com, jeffm@suse.com, jslaby@suse.cz
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab3IQB3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:29:48 -0400
In-Reply-To: <20130916210141.GB14221@oc0268524204.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 16 Sep 2013 18:01:41 -0300

> Sorry for the noise. I just checked again the bug, and had to read
> between the lines that this issue might happen with the generation of
> initrd, when the scripts check for /sys/class/net/eth0/device/modalias,
> which links to the port device at
> /sys/devices/ibmebus/23c00400.lhea/port0/.
> 
> I think that should be clarified in the log message. Besides that, since
> this has also been in the field for a long time:
> 
> Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

I adjusted the commit message and applied this, thanks.
