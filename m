From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: linux-next: Tree for Jan 19 (cisco/enic)
Date: Thu, 19 Jan 2012 21:33:45 -0800
Message-ID: <CB3E3CB9.412EA%roprabhu@cisco.com>
References: <4F18AA99.8010803@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Christian Benvenuti (benve)" <benve@cisco.com>,
	"David Wang (dwang2)" <dwang2@cisco.com>
To: Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:61080 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab2ATFdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 00:33:50 -0500
In-Reply-To: <4F18AA99.8010803@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 1/19/12 3:43 PM, "Randy Dunlap" <rdunlap@xenotime.net> wrote:

> On 01/18/2012 05:59 PM, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Changes since 20120118:
> 
> 
> on x86_64:
> 
> /next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c: In
> function 'enic_probe':
> /next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c:2387:16:
> error: 'struct enic' has no member named 'num_vfs'
> /next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c:2387:32:
> error: 'struct enic' has no member named 'num_vfs'
> 
> 
> Full randconfig file is attached.
> 
> --
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
Thanks for reporting stephen. Its because you don't have CONFIG_PCI_IOV
enabled. I will working on the patch. Will submit soon.
