From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 16:20:39 -0700
Message-ID: <46F1AEC7.8090604@hp.com>
References: <20070918.151528.84360712.davem@davemloft.net> <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:48037 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132AbXISXV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 19:21:29 -0400
In-Reply-To: <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>+#define DRV_MODULE_NAME		"niu"
>>+#define PFX DRV_MODULE_NAME	": "
>>+#define DRV_MODULE_VERSION	"0.06"
>>+#define DRV_MODULE_RELDATE	"September 18, 2007"
>>+
>>+static char version[] __devinitdata =
>>+	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
>>+
>>+MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
>>+MODULE_DESCRIPTION("NIU ethernet driver");
>>+MODULE_LICENSE("GPL");
>>+MODULE_VERSION(DRV_MODULE_VERSION);

A somewhat pedantic question... some grepping in a kernel tree suggests 
the obvious name "netptune" is at least already taken for PCI ID macros:

hpcpc105:~/linux-2.6.23-rc5# grep -i neptune ./drivers/scsi/lpfc/lpfc_hw.h
#define PCI_DEVICE_ID_NEPTUNE       0xf0f5
#define PCI_DEVICE_ID_NEPTUNE_SCSP  0xf0f6
#define PCI_DEVICE_ID_NEPTUNE_DCSP  0xf0f7

and shows-up in comments elsewhere, but that same (perhaps too cursory?) 
search didn't seem to find "neptune" used as  an actual module/driver 
name, so why "niu?"  To what does niu translate anyway?

sincerely,

rick jones
now left with the quandry of whether to run netperf against a driver for 
a card from a .com other than his own or an OEM :) On the plus side 
though, this driver has no EULA restrictions :)
