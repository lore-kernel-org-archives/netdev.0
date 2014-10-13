From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [2/2] dsa: Replace mii_bus with a generic host device
Date: Mon, 13 Oct 2014 10:51:43 -0700
Message-ID: <20141013175143.GA30743@roeck-us.net>
References: <20140915170024.1261.97226.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	kernel@wantstofly.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:47732 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbaJMRvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 13:51:49 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so6238185pab.10
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 10:51:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140915170024.1261.97226.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 01:00:27PM -0400, Alexander Duyck wrote:
> This change makes it so that instead of passing and storing a mii_bus we
> instead pass and store a host_dev.  From there we can test to determine the
> exact type of device, and can verify it is the correct device for our switch.
> 
> So for example it would be possible to pass a device pointer from a pci_dev
> and instead of checking for a PHY ID we could check for a vendor and/or device
> ID.
> 

Hi Alexander,

We are thinking about porting a PCIe based switch to use the DSA infrastructure,
so this patch is coming quite handy.

Have you been working on a port or a PCIe based chip to DSA yourself, by any
chance ? If yes, could you possibly share the current state ?
That might save us some time.

Thanks,
Guenter
