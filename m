From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] [PATCH 2.6.31-rc9] net: VMware virtual Ethernet
 NIC driver: vmxnet3
Date: Tue, 29 Sep 2009 12:55:30 -0700 (PDT)
Message-ID: <20090929.125530.31894576.davem@davemloft.net>
References: <20090929085333.GC3958@sequoia.sous-sol.org>
	<200909291505.50961.arnd@arndb.de>
	<8B1F619C9F5F454E81D90D3C161698D7017DB76582@EXCH-MBX-3.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, chrisw@sous-sol.org, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, greg@kroah.com,
	anthony@codemonkey.ws, jgarzik@pobox.com,
	akpm@linux-foundation.org, shemminger@linux-foundation.org
To: bhavesh@vmware.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754031AbZI2TzN@vger.kernel.org>
In-Reply-To: <8B1F619C9F5F454E81D90D3C161698D7017DB76582@EXCH-MBX-3.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Tue, 29 Sep 2009 12:52:05 -0700

>> One thing that should possibly be fixed is the naming of identifiers,
>> e.g.
>> 's/Vmxnet3_MiscConf/vmxnet3_misc_conf/g', unless these header files are
>> shared with the host implementation.
> 
> These header files are indeed shared with the host implementation, as you've guessed. If it's not a big deal, we would like to keep the names the same, just for our own sanity's sake?

No.  This isn't your source tree, it's everyone's.  So you should
adhere to basic naming conventions and coding standards of the
tree regardless of what you happen to use or need to use internally.
