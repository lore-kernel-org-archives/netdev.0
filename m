From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: NIC on 2.4.19 SMP (mii-diag output)
Date: Sat, 26 Oct 2002 21:59:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <288F9BF66CD9D5118DF400508B68C44604758C6A@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Garzik <jgarzik@pobox.com>, Linux-net <linux-net@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Paul Hernandez'" <ph@digitalquake.com>,
   Donald Becker
	 <becker@scyld.com>,
   Felipe W Damasio <felipewd@terra.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul wrote: 
> Just tried 2.4.20-pre11 and all NIC issues seem to be 
> resolved. Both eepro100 and e100 drivers work correctly.

Just for kicks, go back to 2.4.19.SuSE-SMP, but this time disable ACPI.
(Set acpi=off in the kernel parameters SuSE's bootloader).  Do the nics
work?

We've seen issues on some of these newer systems with multiple IO-APICS
where the interrupts get masked off when ACPI is enabled. 

-scott
