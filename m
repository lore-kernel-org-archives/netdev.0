From: Jan Oravec <jan.oravec@6com.sk>
Subject: VLAN remove problem
Date: Tue, 9 Sep 2003 12:58:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030909105850.GA10034@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

try (on 2.6.0-test5):

vconfig add eth0 47
ip link set eth0.47 up

wait for IPv6 link-local address to appear

ip addr del fe80::something/64 dev eth0.47
vconfig rem eth0.47


the result - never ending:

unregister_netdevice: waiting for eth0.47 to become free. Usage count = 1

Reference is probably not cleared when link-local address is removed.


Best Regards,

-- 
Jan Oravec                           XS26 coordinator
6COM s.r.o.                          'Access to IPv6'
http://www.6com.sk                   http://www.xs26.net
