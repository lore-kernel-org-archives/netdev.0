From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3777] New: tun driver fails to open when built
 in, must be modular
Date: Fri, 19 Nov 2004 15:08:08 -0800
Message-ID: <20041119150808.578154d3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 19 Nov 2004 14:19:35 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3777] New: tun driver fails to open when built in, must be modular


http://bugme.osdl.org/show_bug.cgi?id=3777

           Summary: tun driver fails to open when built in, must be modular
    Kernel Version: 2.6.10-rc2
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: bill@crowellsystems.com


Distribution: slackware/mfxlinux
Hardware Environment:i386
Software Environment:
Problem Description: kernel will not assign/open a tun device when tun.o is
compiled as a built-in. ifconfig gives 'unable to open /dev/net/tun' error.
compiling as a module fixes.

Steps to reproduce:
Compile kernel with tun/tap device driver as a built-in. Run ifconfig to see
error. recompile as a module, modprobe tun and run ifconfig - no error.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
