From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4451] New: VIA Rhine II: media detection fails
 on reboot.
Date: Wed, 6 Apr 2005 14:22:32 -0700
Message-ID: <20050406142232.7a8803fe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, thomas@easyspeedy.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 6 Apr 2005 05:35:33 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4451] New: VIA Rhine II: media detection fails on reboot.


http://bugme.osdl.org/show_bug.cgi?id=4451

           Summary: VIA Rhine II: media detection fails on reboot.
    Kernel Version: 2.6.9
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: thomas@easyspeedy.com


Distribution: Fedora Core 3 / RIP Linux 11.8 / RIP Linux 12.3   
Hardware Environment: DFI PM12-TL   
Software Environment: Kernel 2.6.9+   
Problem Description: The changes introduced in 2.6.9 cause media detection to   
fail after reboot on DFI PM12-TL. Doing a halt -p results in the same problem  
on next boot. It is necessary to disconnect power completely to restore the  
chip to a working state.  
  
Snip from changelog:  
-----------------------------------  
<rl@hellgate.ch>  
	[PATCH] Restructure reset code  
	  
	Restructure code to make it easier to maintain.  
	  
	rhine_hw_init: resets chip, reloads eeprom  
	rhine_chip_reset: chip reset + what used to be wait_for_reset  
	rhine_reload_eeprom: reload eeprom, re-enable MMIO, disable  
EEPROM-controlled  
		WOL  
	  
	Note: Chip reset clears a bunch of registers that should be reloaded  
	from EEPROM (which turns off MMIO). Deal with that later.  
	  
	Signed-off-by: Roger Luethi <rl@hellgate.ch>  
---------------------------------  
 
Kernels tested: 2.6.9, 2.6.11.6, 2.6.12-rc2 
   
Steps to reproduce: Boot 2.6.9 or later on DFI PM12-TL and reboot.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
