From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sun, 22 Jul 2012 14:53:05 -0700 (PDT)
Message-ID: <20120722.145305.46041813959299163.davem@davemloft.net>
References: <20120722.122405.1220712908232591030.davem@davemloft.net>
	<20120722.123733.1898891964192153293.davem@davemloft.net>
	<1342993193.23226.0.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab2GVVxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 17:53:06 -0400
In-Reply-To: <1342993193.23226.0.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 22 Jul 2012 14:39:53 -0700

> On Sun, 2012-07-22 at 12:37 -0700, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Sun, 22 Jul 2012 12:24:05 -0700 (PDT)
>> 
>> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> > Date: Sat, 21 Jul 2012 16:08:49 -0700
>> > 
>> >> This series contains updates to ixgbe and ixgbevf.
>> >> 
>> >> The following are changes since commit
>> 186e868786f97c8026f0a81400b451ace306b3a4:
>> >>   forcedeth: spin_unlock_irq in interrupt handler fix
>> >> and are available in the git repository at:
>> >>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
>> master
>> > 
>> > Pulled, thanks Jeff.
>> 
>> Can you guys actually build test this stuff? 
> 
> I did, but it appears I did not have PCI_IOV enabled.  That was my bad,
> sorry.

If you're not doing "allmodconfig" builds, there are by definition
parts you are not testing.  It's the first thing I do with any change
I apply.
