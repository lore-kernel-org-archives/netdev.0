From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Fri, 14 Sep 2007 15:33:15 -0700 (PDT)
Message-ID: <20070914.153315.39168469.davem@davemloft.net>
References: <1189105530.4852.8.camel@dell>
	<20070906.125019.104036964.davem@davemloft.net>
	<1189218381.5210.67.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, ananth@broadcom.com,
	nsankar@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:40082
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757521AbXINWdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 18:33:20 -0400
In-Reply-To: <1189218381.5210.67.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 07 Sep 2007 19:26:21 -0700

> [PCI]: Add MSI quirk for ServerWorks HT1000 PCIX bridge.
> 
> This is the fix for the following problem:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=227657
> 
> The bnx2 device 5706 complains about MSI not working behind a
> ServerWorks HT1000 PCIX bridge. An earlier commit to fix the problem:
> 
> e3008dedff4bdc96a5f67224cd3d8d12237082a0:
> 
> "PCI: disable MSI by default on systems with Serverworks HT1000 chips"
> 
> was not entirely correct, and has been reverted.
> 
> MSI does not work on the PCIX bus because the BIOS did not set the
> HT_MSI_FLAGS_ENABLE bit in the HyperTransport MSI capability on the
> bridge.  We use the existing quirk_msi_ht_cap() to detect the problem
> and disable MSI in all buses behind it.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Cc: Anantha Subramanyam <ananth@broadcom.com>
> Cc: Naren Sankar <nsankar@broadcom.com>

Michael, I've queued this and my revert patch into a tree which
I will push to the PCI maintainer for 2.6.24

Thanks.
