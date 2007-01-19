From: Patrick McHardy <kaber@trash.net>
Subject: bonding: sysfs patch broke module renaming
Date: Fri, 19 Jan 2007 14:33:07 +0100
Message-ID: <45B0C893.1090809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61229 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965125AbXASNdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 08:33:10 -0500
To: mitch.a.williams@intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sysfs patch broke using multiple instances of the bonding module
through module renaming (modprobe -o). In recent kernels it fails
with -EEXIST when trying to add the bonding_masters file for the
second time, in older kernels (where sysfs_add_file didn't check
for duplicates) it will crash when unloading the modules.

I don't see a good way to fix it, can someone please look into this?
