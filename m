From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [E1000-devel] randconfig build error with next-20150302, in
 drivers/net/ethernet/intel/i40e/i40e_configfs.c
Date: Mon, 2 Mar 2015 14:39:32 -0800 (PST)
Message-ID: <alpine.NEB.2.11.1503021438100.17818@chris.i8u.org>
References: <CA+r1ZhiO8i7b4XQatEX-9X12M9hYPo5F51wrOCYdA8JSMOHnpg@mail.gmail.com> <6D2AF351-FC1E-45DB-AFC9-AFED3284DC7E@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6D2AF351-FC1E-45DB-AFC9-AFED3284DC7E@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Mar 2015, Nicholas Krause wrote:

> On March 2, 2015 11:29:12 AM EST, Jim Davis <jim.epost@gmail.com> wrote:
>> Building with the attached random configuration file,
>>
>> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
>> i40e_configfs.c:(.text+0x3df4ce): undefined reference to
>> `config_item_init_type_name'
>> drivers/built-in.o: In function `i40e_configfs_init':
>> (.text+0x3df4ee): undefined reference to `config_group_init'
>> drivers/built-in.o: In function `i40e_configfs_init':
>> (.text+0x3df50c): undefined reference to `configfs_register_subsystem'
>> drivers/built-in.o: In function `i40e_configfs_exit':
>> (.text+0x3df52e): undefined reference to
>> `configfs_unregister_subsystem'
>> Makefile:939: recipe for target 'vmlinux' failed
>
> Jim,
> I am on my phone so unfortunately I can't help now however, I can send in a patch later fixing this on Linux next. All I need is for you to resend directly to my email your.conf file for this rand configuration that is build failing.
> Nick

Jim, please keep in mind that Nick has not official connection to this
project and has been banned from most of these mailing lists.

-- 
Hisashi T Fujinaka - htodd@twofifty.com
(also todd.fujinaka@intel.com)
