From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4273] New: eepro100 driver discards (big but
 valid) packets
Date: Wed, 2 Mar 2005 03:04:50 -0800
Message-ID: <20050302030450.2b84b3d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 2 Mar 2005 03:00:42 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4273] New: eepro100 driver discards (big but valid) packets


http://bugme.osdl.org/show_bug.cgi?id=4273

           Summary: eepro100 driver discards (big but valid) packets
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: pmarek@cpan.org


Distribution: debian unstable
Hardware Environment: x86, P4 1,7GHz
Software Environment: clean 2.6.10 kernel, cisco vpnclient 4.0.5, 4.0.6
Problem Description:

Copied from
http://www.cisco.com/en/US/products/sw/secursw/ps2308/prod_release_note09186a00802d398a.html#wp1388727
:
  CSCee60154

  After making a VPN Client connection, some traffic types no longer work.
  Specifically applications that send large packets like SMTP, HTTP, and SSH.

  The 2.6.4 Kernel enabled a feature of certain Ethernet cards that discards
  packets larger than the configured MTU. Since the VPN Client lowers the MTU
  visible to the applications in order to add its overhead without exceeding the
  original MTU, the resulting packets are bigger than the newly configured MTU.
  Therefore the card throws out the large encrypted packets. 


Steps to reproduce:
install vpnclient, use eepro100 driver. try https, http, cvs or something like that.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
