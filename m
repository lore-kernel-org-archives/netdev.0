From: cliff white <cliffw@osdl.org>
Subject: Ethtool doesn't work on Debian unstable?
Date: Thu, 10 Mar 2005 13:54:35 -0800
Message-ID: <20050310135435.23af10b8@es175>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is wierd. I know I am doing something Real Stupid, but i can't figure it out.

Two systems.  2.6.11 kernel on both systems. 
One runs RedHat 9.0, and ethtool Just Works:
 ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             256
RX Mini:        0
RX Jumbo:       0
TX:             256
Current hardware settings:
RX:             64
RX Mini:        0
RX Jumbo:       0
TX:             64
--------------------
The other is Debian unstable, and nothing works:
 ethtool -g eth0
Ring parameters for eth0:
Cannot get device ring settings: Operation not supported
------------------------
If i strace, i see the ioctl failing on the Debian side:
7657  munmap(0xb7fd6000, 75321)         = 0
7657  socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
7657  fstat64(1, {st_mode=S_IFCHR|0600, st_rdev=makedev(136, 5), ...}) = 0
7657  mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe8000
7657  write(1, "Ring parameters for eth1:\n", 26) = 26
7657  ioctl(3, SIOCETHTOOL, 0xbffffd30) = -1 EOPNOTSUPP (Operation not supported)
7657  dup(2)                            = 4
------------------------
Can anyone help me here? I'd like to use Debian for this testing, but so far, no love.
cliffw


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
