From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100 changes in git-netdev-all break reboot with netconsole
Date: Thu, 28 Sep 2006 07:53:46 -0700
Message-ID: <451BE1FA.3070804@intel.com>
References: <20060928011516.54a38d4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32441 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1161167AbWI1O4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 10:56:18 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060928011516.54a38d4f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Enable netconsole-over-e100, and `reboot -f' hangs.  Disabling netconsole
> prevents that from happening.
> 
> I assume what's happening is that the driver gets shut down and then
> something tries to do a printk through it, and things hang.
> 
> For some reason sysrq-B still reboots the machine.

okay, I guess that means I'm setting up netconsole today ;)

digging into this ...

Auke
