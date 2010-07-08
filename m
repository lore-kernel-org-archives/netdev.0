From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] ixgbe: fix crashing with ixgbe_vlan_filter_enable
Date: Wed, 07 Jul 2010 18:35:19 -0700
Message-ID: <4C352B57.2050807@kernel.org>
References: <4C350991.6080002@kernel.org> <EA929A9653AAE14F841771FB1DE5A1365FF492082D@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28733 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838Ab0GHBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 21:39:13 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF492082D@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2010 04:31 PM, Tantilov, Emil S wrote:
> Yinghai Lu wrote:
>> happens with reboot or call kexec on system with ixgbe.
>>
>> [ 4912.773390] BUG: unable to handle kernel NULL pointer dereference
>> [ 4912.785756] IP: [<ffffffff81691600>]
>> ixgbe_vlan_filter_enable+0x74/0xda [ 4912.794084] PGD 10391a0067 PUD
>> 1022e3c067 PMD 0 [ 4912.805976] Oops: 0000 [#1] SMP
...
> There should be a patch in net-2.6 that fixes this issue:
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=fa37813401ff52d78591c262d6542e4d5d935584

That fixes the problem.

Thanks

Yinghai
