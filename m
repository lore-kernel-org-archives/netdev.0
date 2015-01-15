From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 12:34:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC9AB0@AcuExch.aculab.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:65116 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbbAOMgd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 07:36:33 -0500
In-Reply-To: <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> The netdev name at init time often defaults to eth0 but later gets changed
> by UDEV, so printing it here is misleading.

Without the interface name you stand zero chance of working out which one it is.
With it, and provided all the interface renames get into dmesg, you stand
at least some chance.

If you have several interfaces that use the same driver, but are subtly
different you can have a hard enough time as it is working out what is
going on.

I know it is too late now, but UDEV should never have been allowed to
rename devices, instead it should have added 'alias' names.
Then you would stand some chance of working out which was which.

> This patch removes the name
> from the log messages, and removes the use of __func__ as we're not using
> that any more in the driver.

I can't remember, do these messages contain the name of the driver (as
well as the device id string).
You might need some help when grepping the kernel source to find where
the messages are coming from.

	David
