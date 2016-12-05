From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH V2 net 00/20] Increase ENA driver version to 1.1.2
Date: Sun, 4 Dec 2016 19:30:40 -0800
Message-ID: <20161205033040.GA4310@u54ee753d2d1854bda401.ant.amazon.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <20161204.213743.1610654756480441815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netanel@annapurnalabs.com>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <dwmw@amazon.com>,
        <zorik@annapurnalabs.com>, <alex@annapurnalabs.com>,
        <saeed@annapurnalabs.com>, <msw@amazon.com>, <aliguori@amazon.com>,
        <nafea@annapurnalabs.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.189.228]:30824 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcLEDbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 22:31:16 -0500
Content-Disposition: inline
In-Reply-To: <20161204.213743.1610654756480441815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 09:37:43PM -0500, David Miller wrote:
> 
> It is not appropriate to submit so many patches at one time.

Indeed, https://www.kernel.org/doc/Documentation/SubmittingPatches
recommends submitting no more than 15 or so at once.

> Please keep your patch series to no more than about a dozen
> at a time.

How about 15 from SubmittingPatches? The first 15 in the series are
all important bugfixes. Should Netanel resubmit a series with just the
bugfixes and a new cover letter? Or are you willing to consider the
first 15 of this series as posted?

> Also, group your changes logically and tie an appropriately
> descriptive cover letter.
> 
> "Increase driver version to X.Y.Z" tells the reader absolutely
> nothing.  Someone reading that Subject line in the GIT logs
> will have no idea what the overall purpose of the patch series
> is and what it accomplishes.

You're right, the cover letter subject needs to be better. There is
only one commit submitted with the subject "increase driver version to
1.1.2." - Patch 20/20. It is logically like:

commit b8b2372de9cc00d5ed667c7b8db29b6cfbf037f5
Author: Manish Chopra <manish.chopra@qlogic.com>
Date:   Wed Aug 3 04:02:04 2016 -0400

    qlcnic: Update version to 5.3.65
    
    Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

[...]

commit ae33256c55d2fefcad8712e750b846461994a1af
Author: Bimmy Pujari <bimmy.pujari@intel.com>
Date:   Mon Jun 20 09:10:39 2016 -0700

    i40e/i40evf-bump version to 1.6.11
    
    Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
    Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]

commit 5264cc63ba10ebfa0e54e3e641cce2656c7a60e8
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Tue Jun 7 16:09:02 2016 -0700

    fm10k: bump version number
    
    Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
    Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]

commit a58a3e68037647de78e3461194239a1104f76003
Author: Michael Chan <michael.chan@broadcom.com>
Date:   Fri Jul 1 18:46:20 2016 -0400

    bnxt_en: Update firmware spec. to 1.3.0.
    
    And update driver version to 1.3.0.
    
    Signed-off-by: Michael Chan <michael.chan@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

> You really need to describe the high level purpose of the patch set.
> Is it adding a new feature?  What is that feature?  Why are you
> adding that feature?  How is that feature implemented?  Why is
> it implemented that way?

The priority is to get bug fixes to the ENA driver in 4.9. Let's focus
on the first 15.

--msw
