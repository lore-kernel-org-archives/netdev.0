From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: netconsole build breakage (Re: [GIT] Networking)
Date: Wed, 19 Jan 2011 18:08:24 +0800
Message-ID: <20110119100824.GD9903@cr0.nay.redhat.com>
References: <20110114.130323.201674039.davem@davemloft.net>
 <20110119095920.GA10543@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	James Bottomley <James.Bottomley@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110119095920.GA10543@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 19, 2011 at 10:59:20AM +0100, Ingo Molnar wrote:
>
>FYI, there's a .38-rc1 build failure that triggers rather often:
>
> drivers/built-in.o: In function `drop_netconsole_target':
> netconsole.c:(.text+0x130146): undefined reference to `config_item_put'
> drivers/built-in.o: In function `write_msg':
> netconsole.c:(.text+0x1301aa): undefined reference to `config_item_get'
> netconsole.c:(.text+0x130217): undefined reference to `config_item_put'
> drivers/built-in.o: In function `netconsole_netdev_event':
> netconsole.c:(.text+0x1302ab): undefined reference to `config_item_get'
> ...
>
>Triggered by this configuration:
>
> CONFIG_CONFIGFS_FS=m
> CONFIG_NETCONSOLE=y
>

Should be "depends on CONFIGFS_FS=y".
