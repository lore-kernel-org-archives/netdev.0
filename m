From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [lkp-robot] [irda]  66d98e78e4: BUG:unable_to_handle_kernel
Date: Wed, 30 Aug 2017 08:12:15 +0200
Message-ID: <20170830061215.GA3682@kroah.com>
References: <20170827150334.32495-2-gregkh@linuxfoundation.org>
 <20170830060410.GX30390@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, samuel@sortiz.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, lkp@01.org, davem@davemloft.net
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20170830060410.GX30390@yexl-desktop>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 02:04:11PM +0800, kernel test robot wrote:
> FYI, we noticed the following commit:
> 
> commit: 66d98e78e44ccb969cb3196995759d200e64b49b ("irda: move net/irda/ to drivers/staging/irda/net/")
> url: https://github.com/0day-ci/linux/commits/Greg-Kroah-Hartman/irda-move-it-to-drivers-staging-so-we-can-delete-it/20170829-090816
> 
> in testcase: trinity
> with following parameters:
> 
> 	runtime: 300s
> 
> test-description: Trinity is a linux system call fuzz tester.
> test-url: http://codemonkey.org.uk/projects/trinity/
> 
> on test machine: qemu-system-i386 -enable-kvm -smp 2 -m 320M
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> +-----------------------------------------------------+------------+------------+
> |                                                     | 89ff9d58e6 | 66d98e78e4 |
> +-----------------------------------------------------+------------+------------+
> | boot_successes                                      | 0          | 0          |
> | boot_failures                                       | 10         | 12         |
> | IP-Config:Auto-configuration_of_network_failed      | 8          |            |
> | WARNING:at_arch/x86/mm/dump_pagetables.c:#note_page | 2          |            |
> | EIP:note_page                                       | 2          |            |
> | BUG:unable_to_handle_kernel                         | 0          | 12         |
> | Oops:#[##]                                          | 0          | 12         |
> | EIP:dev_add_pack                                    | 0          | 12         |
> | Kernel_panic-not_syncing:Fatal_exception            | 0          | 12         |
> +-----------------------------------------------------+------------+------------+
> 
> [    0.227015] BUG: unable to handle kernel NULL pointer dereference at 00000004
> [    0.228000] IP: dev_add_pack+0x37/0x80

Didn't you report this yesterday as well?  Anyway, am working on it,
give me a few hours to wake up and test...

thanks,

greg k-h
