From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'libertas' branch of wireless-2.6 (resent w/o attachment)
Date: Tue, 12 Jun 2007 22:28:21 -0400
Message-ID: <466F5645.1060501@garzik.org>
References: <20070529183347.GD3496@tuxdriver.com> <20070612210544.GF310@tuxdriver.com> <20070612212641.GI310@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60202 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752611AbXFMC2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 22:28:24 -0400
In-Reply-To: <20070612212641.GI310@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Resending w/o the attached patch, in case it was too big...yikes!
> 
> Individual patches are available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/libertas
> 
> John
> 
> ---
> 
> Jeff,
> 
> This is the same as the previous pull request, only rebased on
> 2.6.22-rc4.  Since this is a big pull already, I didn't want to
> complicate it with the additional patches identified by the libertas
> team as 2.6.22-worthy.
> 
> John
> 
> ---
> 
> The following changes since commit 5ecd3100e695228ac5e0ce0e325e252c0f11806f:
>   Linus Torvalds (1):
>         Linux 2.6.22-rc4
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas
> 
> Chris Ball (1):
>       libertas: wakeup both mesh and normal wakeup when getting out of scan
> 
> Dan Williams (25):
>       libertas: call SET_NETDEV_DEV from common code
>       libertas: replace 'macaddress' with 'bssid'
>       libertas: correctly unregister mesh netdev on error
>       libertas: don't tear down netdev in libertas_activate_card
>       libertas: make scan result handling more flexible
>       libertas: fix 'keep previous scan' behavior
>       libertas: move channel changing into association framework
>       libertas: make association paths consistent
>       libertas: use MAC_FMT and MAC_ARG where appropriate
>       libertas: use compare_ether_addr() rather than memcmp() where appropriate
>       libertas: fix debug enter/leave prints for libertas_execute_next_command
>       libertas: correctly balance locking in libertas_process_rx_command
>       libertas: correct error report paths for wlan_fwt_list_ioctl
>       libertas: fix deadlock SIOCGIWSCAN handler
>       libertas: fix default adhoc channel
>       libertas: honor specific channel requests during association
>       libertas: send SIOCGIWSCAN event after partial scans too
>       libertas: debug print spacing fixes in assoc.c
>       libertas: add more verbose debugging to libertas_cmd_80211_authenticate
>       libertas: Make WPA work through supplicant handshake
>       libertas: sparse fixes
>       libertas: tweak association debug output
>       libertas: remove structure WLAN_802_11_SSID and libertas_escape_essid
>       libertas: remove WPA_SUPPLICANT structure
>       libertas: reduce SSID and BSSID mixed-case abuse
> 
> David Woodhouse (6):
>       libertas: fix character set in README
>       libertas: first pass at fixing up endianness issues
>       libertas: More endianness fixes.
>       libertas: more endianness fixes, in tx.c this time
>       libertas: don't byte-swap firmware version number. It's a byte array.
>       libertas: fix big-endian associate command.
> 
> Holger Schurig (23):
>       libertas: rename wlan_association_worker
>       libertas: a debug output was missing a newline
>       libertas: fix removal of all debugfs files
>       libertas: remove __FILE__ from debug output
>       libertas: remove unused/superfluous definitions of DEV_NAME_LEN
>       libertas: move vendor & product id's into if_usb.c
>       libertas: make libertas_wlan_data_rates static
>       libertas: exclude non-used code when PROC_DEBUG is not set
>       libertas: make debug configurable
>       libertas: tune debug code
>       libertas: single out mesh code
>       libertas: change debug output of libertas_interrupt()
>       libertas: get rid of libertas_sbi_get_priv()
>       libertas: fix SSID output
>       libertas: changed some occurences of kmalloc() + memset(&a,0,sz) to kzalloc()
>       libertas: move reset_device() code main.c to if_usb.c
>       libertas: split wlan_add_card()
>       libertas: indirect all hardware access via hw_XXXX functions
>       libertas: move contents of fw.h to decl.h
>       libertas: split module into two (libertas.ko and usb8xxx.ko)
>       libertas: fix RESET logic at unload time
>       libertas: let DRV_NAME be overridable
>       libertas: remove unused variables in wlan_dev_t
> 
> Javier Cardona (2):
>       libertas: fixed transmission flow control on the mesh interface
>       libertas: added transmission failures to mesh statistics
> 
> Luis Carlos Cobo (4):
>       libertas: fixed incorrect assigment of fcs errors to frag errors
>       libertas: add URB debug info
>       libertas: fixed kernel oops on module/card removal
>       libertas: updated mesh commands for 5.220.9.p11
> 
> Luis Carlos Cobo Rus (6):
>       libertas: version bump (321p0) and cmds update for new fw (5.220.10.p0)
>       libertas: cleanup of fwt_list_route processing
>       libertas: updated readme file
>       libertas: make mac address configuration work with mesh interface too
>       libertas: split wext for eth and msh
>       libertas: support for mesh autostart on firmware 5.220.11
> 
> Marcelo Tosatti (5):
>       libertas: scan two channels per scan command
>       libertas: remove deprecated pm_register and associated code
>       libertas: fix scanning from associate path
>       libertas: fix error handling of card initialization
>       libertas: fix oops on rmmod
> 
>  drivers/net/wireless/Kconfig               |   19 +-
>  drivers/net/wireless/libertas/11d.c        |  152 ++--
>  drivers/net/wireless/libertas/11d.h        |    6 +-
>  drivers/net/wireless/libertas/Makefile     |    4 +-
>  drivers/net/wireless/libertas/README       |   52 +-
>  drivers/net/wireless/libertas/assoc.c      |  345 +++++---
>  drivers/net/wireless/libertas/assoc.h      |    8 +-
>  drivers/net/wireless/libertas/cmd.c        |  559 +++++------
>  drivers/net/wireless/libertas/cmdresp.c    |  375 ++++----
>  drivers/net/wireless/libertas/debugfs.c    |  432 ++++----
>  drivers/net/wireless/libertas/decl.h       |   20 +-
>  drivers/net/wireless/libertas/defs.h       |  101 ++-
>  drivers/net/wireless/libertas/dev.h        |   98 +-
>  drivers/net/wireless/libertas/ethtool.c    |   55 +-
>  drivers/net/wireless/libertas/fw.c         |  111 +--
>  drivers/net/wireless/libertas/fw.h         |   13 -
>  drivers/net/wireless/libertas/host.h       |   13 +-
>  drivers/net/wireless/libertas/hostcmd.h    |  392 ++++----
>  drivers/net/wireless/libertas/if_bootcmd.c |    6 +-
>  drivers/net/wireless/libertas/if_usb.c     |  448 +++++----
>  drivers/net/wireless/libertas/if_usb.h     |   32 +-
>  drivers/net/wireless/libertas/ioctl.c      |  286 ++++--
>  drivers/net/wireless/libertas/join.c       |  464 ++++-----
>  drivers/net/wireless/libertas/join.h       |   13 +-
>  drivers/net/wireless/libertas/main.c       |  673 ++++++-------
>  drivers/net/wireless/libertas/rx.c         |   63 +-
>  drivers/net/wireless/libertas/sbi.h        |   40 -
>  drivers/net/wireless/libertas/scan.c       | 1529 +++++++++++++---------------
>  drivers/net/wireless/libertas/scan.h       |   81 +-
>  drivers/net/wireless/libertas/thread.h     |    8 +-
>  drivers/net/wireless/libertas/tx.c         |   74 +-
>  drivers/net/wireless/libertas/types.h      |   63 +-
>  drivers/net/wireless/libertas/wext.c       |  778 ++++++++-------
>  drivers/net/wireless/libertas/wext.h       |   13 +-
>  34 files changed, 3679 insertions(+), 3647 deletions(-)
>  delete mode 100644 drivers/net/wireless/libertas/fw.h
>  delete mode 100644 drivers/net/wireless/libertas/sbi.h

pulled into #upstream-fixes

