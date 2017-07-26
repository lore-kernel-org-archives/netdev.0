From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver
 Updates 2017-07-25
Date: Wed, 26 Jul 2017 16:59:04 -0700 (PDT)
Message-ID: <20170726.165904.261037349393344966.davem@davemloft.net>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdGZX7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 19:59:06 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 26 Jul 2017 03:31:09 -0700

> This series contains updates to i40e and i40evf only.
> 
> Gustavo Silva fixes a variable assignment, where the incorrect variable
> was being used to store the error parameter.
> 
> Carolyn provides a fix for a problem found in systems when entering S4
> state, by ensuring that the misc vector's IRQ is disabled as well.
> 
> Jake removes the single-threaded restriction on the module workqueue,
> which was causing issues with events such as CORER.  Does some future
> proofing, by changing how the driver displays the UDP tunnel type.
> 
> Paul adds a retry in releasing resources if the admin queue times out
> during the first attempt to release the resources.
> 
> Jesse fixes up references to 32bit timspec, since there are a small set
> of errors on 32 bit, so we need to be using the right calls for dealing
> with timespec64 variables.  Cleaned up code indentation and corrected
> an "if" conditional check, as well as making the code flow more clear.
> Cast or changed the types to remove warnings for comparing signed and
> unsigned types.  Adds missing includes in i40evf, which were being used
> but were not being directly included.
> 
> Daniel Borkmann fixes i40e to fill the XDP prog_id with the id just like
> other XDP enabled drivers, so that on dump we can retrieve the attached
> program based on the id and dump BPF insns, opcodes, etc back to user
> space.
> 
> Tushar Dave adds le32_to_cpu while evaluating the hardware descriptor
> fields, since they are in little-endian format.  Also removed
> unnecessary "__packed" to a couple of i40evf structures.
> 
> Stefan Assmann fixes an issue when an administratively set MAC was set
> and should now be switched back to 00:00:00:00:00:00, the pf_set_mac
> flag is not being toggled back to false.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Also pulled, thanks Jeff.
