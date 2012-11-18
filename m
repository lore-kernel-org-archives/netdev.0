From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] PPC: net: bpf_jit_comp: add VLAN
 instructions for BPF JIT
Date: Sat, 17 Nov 2012 22:13:12 -0500 (EST)
Message-ID: <20121117.221312.1811114210288021648.davem@davemloft.net>
References: <20121108214137.GB29696@thinkbox>
	<45EBCE3A-FE92-4A8D-B5D8-DED4E30DF419@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, benh@kernel.crashing.org, netdev@vger.kernel.org
To: matt@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab2KRDNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 22:13:13 -0500
In-Reply-To: <45EBCE3A-FE92-4A8D-B5D8-DED4E30DF419@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Evans <matt@ozlabs.org>
Date: Sat, 17 Nov 2012 00:06:03 +0000

> Hi,
> 
> On 08/11/2012, at 9:41 PM, Daniel Borkmann wrote:
> 
>> This patch is a follow-up for patch "net: filter: add vlan tag access"
>> to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>> Cc: Matt Evans <matt@ozlabs.org>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> ---
>> Disclaimer: uncompiled and untested, since I don't have a PPC machine,
>> but it should (hopefully) integrate cleanly; impl. after PPC instruction
>> reference.
> 
> And for this too,
> 
> Acked-by: Matt Evans <matt@ozlabs.org>
> 
> Sorry for the delay in reviewing this!

Applied, thanks for reviewing.
