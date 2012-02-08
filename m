From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/8] igb: fix vf lookup
Date: Wed, 08 Feb 2012 18:52:44 -0500 (EST)
Message-ID: <20120208.185244.1488314318862923939.davem@davemloft.net>
References: <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
	<1328744980.6909.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757830Ab2BHXwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 18:52:50 -0500
In-Reply-To: <1328744980.6909.8.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 08 Feb 2012 15:49:40 -0800

> On Wed, 2012-02-08 at 23:42 +0000, Rose, Gregory V wrote:
>> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> []
>> > @@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct igb_adapter
>> > *adapter)
>> >  	vf_devfn = pdev->devfn + 0x80;
>> >  	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
>> >  	while (pvfdev) {
>> > -		if (pvfdev->devfn == vf_devfn)
>> > +		if (pvfdev->devfn == vf_devfn &&
>> > +		    (pvfdev->bus->number >= pdev->bus->number))
>> >  			vfs_found++;
> []
>> I'll fix this one too.  You start leaning on checkpatch and you get lazy I guess.
> 
> I suppose an indentation rule could be created when
> arguments on multiple lines don't align at the open
> parenthesis, but I'm not going to rewrite emacs
> indentation rules.
> 
> Presumably it should only be used with --strict.
> 
> Anyone think multiple line tests with inequivalent uses
> of parentheses like this one should be noted as well?

Actually I thought this case was perfectly fine.
