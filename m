From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Kernel 2.6.7-rc3
Date: Wed, 23 Jun 2004 09:40:55 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040623134055.GD6253@ruslug.rutgers.edu>
References: <20040610161535.GA3025@aragorn.home.lxtec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <20040610161535.GA3025@aragorn.home.lxtec.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 10, 2004 at 06:15:35PM +0200, Elimar Riesebieter wrote:
> Hi all,
> 
> I had some troble with the the drivers out of vanilla 2.6.7-rc3 and
> 2.6.7-rc2-mm2. Please notice that this happens running on ppc
> plattform!
> 
> This is from dmesg 2.6.7-rc3
> ----------------------------
> 
> eth1: islpci_open()
> eth1: resetting device...
> eth1: uploading firmware...
> eth1: firmware uploaded done, now triggering reset...
> eth1: errant PIMFOR application frame
> eth1: timeout waiting for mgmt response 1000, trigging device
> eth1: timeout waiting for mgmt response
> eth1: Out of memory, cannot handle oid 0x5f746567
> eth1: timeout waiting for mgmt response 1000, trigging device
> eth1: timeout waiting for mgmt response
> eth1: errant PIMFOR application frame
> eth1: timeout waiting for mgmt response 1000, trigging device
> eth1: timeout waiting for mgmt respon1se
> eth1: mgt_commit has failed. Restart the device 
> 
> This is a backtrace running 2.6.7-rc3
> -------------------------------------
> Jun 10 17:45:48 aragorn kernel: Bad page state at prep_new_page (in process 'cc1', page c070d020)
> Jun 10 17:45:48 aragorn kernel: flags:0x00000000 mapping:00070000 mapcount:0 count:0
> Jun 10 17:45:48 aragorn kernel: Backtrace:
> Jun 10 17:45:48 aragorn kernel: Call trace:
> Jun 10 17:45:48 aragorn kernel:  [c000b854] dump_stack+0x18/0x28
> Jun 10 17:45:48 aragorn kernel:  [c003cdb0] bad_page+0x5c/0xa4
> Jun 10 17:45:48 aragorn kernel:  [c003d16c] prep_new_page+0x50/0x84
> Jun 10 17:45:48 aragorn kernel:  [c003d7b4] buffered_rmqueue+0x110/0x1b4
> Jun 10 17:45:48 aragorn kernel:  [c003d918] __alloc_pages+0xc0/0x388
> Jun 10 17:45:48 aragorn kernel:  [c0049b34] do_anonymous_page+0x70/0x1ac
> Jun 10 17:45:48 aragorn kernel:  [c0049cdc] do_no_page+0x6c/0x37c
> Jun 10 17:45:48 aragorn kernel:  [c004a1c0] handle_mm_fault+0xf4/0x174
> Jun 10 17:45:48 aragorn kernel:  [c0014bf4] do_page_fault+0x140/0x398
> Jun 10 17:45:48 aragorn kernel:  [c0008118] handle_page_fault+0xc/0x80
> Jun 10 17:45:48 aragorn kernel: Trying to fix it up, but a reboot is needed
> 
> The version out of 2.6.7-rc2-mm1 runs perfect!
> 
> Ciao
> 
> Elimar
> 
> -- 
>   Numeric stability is probably not all that 
>   important when you're guessing;-)


Try 2.6.7-bk6 and if no problems occur then this has been fixed. If not
please submit a bug report. Please note that mgt timeout is a known bug.
This could be related to bug 88. 

http://prism54.org/cgi-bin/bugzilla/show_bug.cgi?id=88

It is actually currently affecting WPA too but I'll send out another
e-mail regarding that.

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
