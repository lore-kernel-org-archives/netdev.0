From: Brandon Philips <brandon@ifup.org>
Subject: [patch 0/5][RFC] Update network drivers to use devres
Date: Thu, 2 Aug 2007 15:42:06 -0700
Message-ID: <20070802224206.GB5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:58691 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbXHBWmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 18:42:09 -0400
Received: by rv-out-0910.google.com with SMTP id k20so524225rvb
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2007 15:42:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds support for devres in the net core and converts the
e100 and e1000 drivers to devres.  Devres is a simple resource manager
for device drivers, see Documentation/driver-model/devres.txt for more
information.

The use of devres will remain optional for drivers with this patch set.
Drivers can be converted when it makes sense.

Builds on top of f0a664bbd1839fbe9f57564983f39bfc6c6f931d in Linus' tree
which renames __pci_reenable_device() to pci_reenable_device()

-- 
