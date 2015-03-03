From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: i40e: fix build, depends on CONFIGFS_FS
Date: Tue, 03 Mar 2015 15:02:07 -0500 (EST)
Message-ID: <20150303.150207.742456888724586407.davem@davemloft.net>
References: <54F60D0A.6020903@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux.nics@intel.com, jeffrey.t.kirsher@intel.com
To: rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F60D0A.6020903@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 03 Mar 2015 11:35:38 -0800

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> i40e uses configfs interfaces so it should depend on CONFIGFS_FS.
> 
> Fixes these build errors:
> 
> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> i40e_configfs.c:(.text+0x2fcdca): undefined reference to `config_item_init_type_name'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x2fcee6): undefined reference to `config_group_init'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x2fcf0c): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `i40e_configfs_exit':
> (.text+0x2fcf71): undefined reference to `configfs_unregister_subsystem'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Intel guys, I am furiously mad.

I've told you guys a thousand times to use portable, reasonable
mechanisms to configure your hardware.  Using facilities that can
be used for other cards from other vendors with similar facilities.

If such portable netdevice configuration frameworks do not exist,
create it.

Every time you make a device specific mechanism for configuration,
a small kitten dies somewhere in the world.

Please remove all of this configfs crap for twiddling bandwidth
et al. knobs, before I do it for you.

Thanks.
