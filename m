From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 16:17:55 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704031424570.3963@sheep.housecafe.de>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
 <46116570.3050109@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:36254 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030327AbXDCPSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 11:18:01 -0400
In-Reply-To: <46116570.3050109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Apr 2007, Chuck Ebbert wrote:
> Where is the info from before you changed to "noapic"? Or were the
> machines always using XT-PIC for all the interrupts???

We booted with 'acpi=off lapic' (with ACPI options compiled in, to be 
able to boot with acpi=on later on) and the box locked up again.

I'll try to boot with a slightly different .config later on. With 
'lapic' /proc/interrupts looks like:

           CPU0       CPU1
   0:      63656      63396   IO-APIC-edge      timer
   1:          0          8   IO-APIC-edge      i8042
   2:          0          0    XT-PIC-XT        cascade
   4:          6          1   IO-APIC-edge      serial
   6:          0          3   IO-APIC-edge      floppy
   8:          0          1   IO-APIC-edge      rtc
  17:      17050          1   IO-APIC-fasteoi   eth1
  18:        102      80615   IO-APIC-fasteoi   eth0
  20:     195817      77721   IO-APIC-fasteoi   libata
NMI:          0          0
LOC:     126969     126970
ERR:          0
MIS:          0

Christian.

-- 
BOFH excuse #146:

Communications satellite used by the military for star wars.
