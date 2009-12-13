From: re.emese@gmail.com
Subject: [PATCH 0/1] Constify struct iwl_ops for 2.6.32-git-053fe57ac v2
Date: Mon, 14 Dec 2009 00:59:52 +0100
Message-ID: <cover.1260662999.git.re.emese__18803.8334170871$1260749688$gmane$org@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	ilw@linux.intel.com, linville@tuxdriver.com,
	reinette.chatre@intel.com, yi.zhu@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34268 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754983AbZLMX56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 18:57:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>

Hello everyone!

The following patch series attempts to constify several structures
that hold function pointers. This is only the initial batch, there
are about over 150 candidate structures, some of which can be
constified as well, I plan to submit them in the future.

The list of constified structures in this series (* marks this thread):
acpi_dock_ops
address_space_operations
backlight_ops
block_device_operations
dma_map_ops
extent_io_ops
file_lock_operations
file_operations
hv_ops
intel_dvo_dev_ops
item_operations
* iwl_ops
kgdb_arch
kgdb_io
kset_uevent_ops
lock_manager_operations
microcode_ops
mtrr_ops
neigh_ops
nlmsvc_binding
pci_raw_ops
platform_hibernation_ops
platform_suspend_ops
snd_ac97_build_ops
sysfs_ops
usb_mon_operations
wd_ops

There are certain exceptions where a given instance of the structure
cannot be const, they are marked with a comment in the patch.

The patches compile fine with an allyesconfig kernel on i386 and x86_64.

Please let me know if any of these structures should not be constified
and any other issues you see with them.


Changelog:
----------
v1 -> v2
	- updated to linus-git-053fe57
	- extended comments with a reference to code that prevents constification
	- split up patches by subsystem as suggested by Greg KH, Jiri Slaby
	- added all Acked-by's received so far
	- removed patch for super_operations for now
	- removed patch for ptmx_fops

Thanks,
   Emese

 drivers/net/wireless/iwlwifi/iwl-1000.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-6000.c |    4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

