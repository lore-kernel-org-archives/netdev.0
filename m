From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3784] New: Kernel Panic on huge portrange TCP
 scan (using nmap portscanner).
Date: Sat, 20 Nov 2004 13:27:49 -0800
Message-ID: <20041120132749.5001bef1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sat, 20 Nov 2004 13:14:27 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3784] New: Kernel Panic on huge portrange TCP scan (using nmap portscanner).


http://bugme.osdl.org/show_bug.cgi?id=3784

           Summary: Kernel Panic on huge portrange TCP scan (using nmap
                    portscanner).
    Kernel Version: Linux version 2.6.9 (slawek@ivision) (gcc version 3.3.4)
                    #1 Sat
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: czkaw@poczta.fm


Distribution: Slackware 10.0 
Hardware Environment:  
  processor       : 0 
vendor_id       : AuthenticAMD 
cpu family      : 6 
model           : 10 
model name      : AMD Athlon(tm) XP 2500+ 
stepping        : 0 
cpu MHz         : 1837.442 
cache size      : 512 KB 
fdiv_bug        : no 
hlt_bug         : no 
f00f_bug        : no 
coma_bug        : no 
fpu             : yes 
fpu_exception   : yes 
cpuid level     : 1 
wp              : yes 
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov 
pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow 
bogomips        : 3629.05 
 
Software Environment: 
 
 Linux ivision 2.6.9 #1 Sat Nov 20 20:38:14 CET 2004 i686 unknown unknown 
GNU/Linux 
 
Gnu C                  3.3.4 
Gnu make               3.80 
binutils               2.15.90.0.3 
util-linux             2.12a 
mount                  2.12a 
module-init-tools      3.0 
e2fsprogs              1.35 
reiserfsprogs          3.6.17 
reiser4progs           line 
Linux C Library        2.3.2 
Dynamic linker (ldd)   2.3.2 
Linux C++ Library      5.0.6 
Procps                 3.2.1 
Net-tools              1.60 
Kbd                    1.12 
Sh-utils               5.2.1 
Modules Loaded  (none) 
 
Problem Description: I've got Kernel Panic when i run 'nmap localhost -p 
1-60000'. It says : Kernel BUG at net/ipv4/tcp_output.c:227. 
 
Steps to reproduce: Install nmap 3.50 ( http://www.insecure.org/nmap/ ) and 
scan with it 60000 ports on localhost 'nmap localhost -p 1-60000' localhost 
should be 127.0.0.1 ( lo interface )

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
