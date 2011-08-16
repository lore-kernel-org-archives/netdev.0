From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 41192] New: acer aspire one d522 locks up due
 to NIC
Date: Tue, 16 Aug 2011 15:00:43 -0700
Message-ID: <20110816150043.96a91094.akpm@linux-foundation.org>
References: <bug-41192-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	willi@goesgens.de
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38883 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751500Ab1HPWBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 18:01:40 -0400
In-Reply-To: <bug-41192-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Aug 2011 12:03:56 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=41192
> 
>            Summary: acer aspire one d522 locks up due to NIC
>            Product: Drivers
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: willi@goesgens.de
>         Regression: No
> 
> 
> Created an attachment (id=68882)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=68882)
> dmesg output of whole system run
> 
> This netbook is equipped with:
> 06:00.0 Ethernet controller: Atheros Communications AR8152 v2.0 Fast Ethernet
> (rev c1)
> 07:00.0 Network controller: Atheros Communications Inc. AR9285 Wireless Network
> Adapter (PCI-Express) (rev 01)
> 
> if there is a network manager probing the cable NIC for the cable status, the
> whole system locks up completely.
> 
> the lockup can be circumvented by: 
>  - not loading the kernel module for the cable NIC
>  - not starting 'network manager' or 'WICD', same problems on both.
>  - turning on the systems netboot agent as pointed out by walterav on
> http://phoronix.com/forums/showthread.php?31961-Notes-on-Acer-Aspire-One-522/page7
> 
> 
> Module                  Size  Used by
> bnep                   17346  2 
> rfcomm                 73852  0 
> bluetooth             252589  10 bnep,rfcomm
> binfmt_misc             7588  1 
> fuse                   70593  1 
> synaptics_i2c_rmi4      7979  0 
> ath9k                  83089  0 
> mac80211              248833  1 ath9k
> ath9k_common            2456  1 ath9k
> ath9k_hw              302986  2 ath9k,ath9k_common
> k10temp                 3378  0 
> uvcvideo               57863  0 
> ath                    15715  2 ath9k,ath9k_hw
> cfg80211              211736  3 ath9k,mac80211,ath
> atl1c                  45270  0 
> rfkill                 19387  3 bluetooth,cfg80211
> sp5100_tco              5392  0 
> i2c_piix4              11482  0 
> mac_hid                 3645  0
> 

