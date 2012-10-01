From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 01 Oct 2012 13:53:56 +0200
Message-ID: <50698454.6000601@redhat.com>
References: <20120928114335.e05b34a5cfe716df86364ccf@canb.auug.org.au> <20120927.221943.19056434713380159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483Ab2JALyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 07:54:07 -0400
In-Reply-To: <20120927.221943.19056434713380159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2012 04:19 AM, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 28 Sep 2012 11:43:35 +1000
> 
>> Hi all,
>>
>> After merging the net-next tree, today's linux-next build (powerpc
>> ppc64_defconfig) failed like this:
>>
>> drivers/net/ethernet/emulex/benet/be_main.c: In function 'be_find_vfs':
>> drivers/net/ethernet/emulex/benet/be_main.c:1090:28: error: 'struct pci_dev' has no member named 'physfn'
>>
>> Caused by commit 51af6d7c1f31 ("be2net: fix vfs enumeration").  physfn is
>> only defined if CONFIG_PCI_ATS is set.
>>
>> I have reverted that commit for today.
> 
> I'm reverting it too, thanks for reporting Stephen.
> 
Sorry for that, it will be better to use pci_physfn to access this
member. I'll repost the patch.

Ivan
