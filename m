From: "Axel Reinhold" <Axel.Reinhold@le-gobw.de>
Subject: Sis900 and VLAN 8021q.o incompatible/MTU troubles
Date: Thu, 12 May 2005 09:43:13 +0200
Message-ID: <200505120743.j4C7hWKI011583@l0p.le-gobw.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear Venza,

my sis900 is running fine in standard mode. Together with 8021q.o
i get
all kinds of troubles - for example samba is no more working at
all -
without vlan everything is fine - with vlans everything basically
works
- but only to a certain point, then it screws up. Is sis900.o
incompatible with 8021q.o? Has the driver the MTU-troubles known
from other
old ethernet drivers?

May 11 20:03:20 bongo kernel: sis900.c: v1.08.07 11/02/2003
May 11 20:03:20 bongo kernel: PCI: Found IRQ 12 for device 00:01.1
May 11 20:03:20 bongo kernel: eth0: SiS 900 Internal MII PHY
transceiver found at address 1.
May 11 20:03:20 bongo kernel: eth0: Using transceiver found at
address 1 as default
May 11 20:03:20 bongo kernel: eth0: SiS 900 PCI Fast Ethernet at
0xd400, IRQ 12, 00:e0:18:3a:db:1a.
May 11 20:03:20 bongo kernel: 802.1Q VLAN Support v1.8 Ben Greear
<greearb@candelatech.com>
May 11 20:03:20 bongo kernel: All bugs added by David S. Miller
<davem@redhat.com>

[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/access.c:check_access(328)
[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/util_sock.c:write_socket_data(430)
  write_socket_data: write failure. Error = Connection reset by
peer
[2005/05/11 21:01:23, 0] lib/util_sock.c:write_socket(455)
  write_socket: Error writing 5 bytes to socket 30: ERRNO =
Connection reset by peer
[2005/05/11 21:01:23, 0] lib/util_sock.c:send_smb(647)
  Error writing 5 bytes to client. -1. (Connection reset by peer)
[2005/05/11 21:23:14, 0] smbd/server.c:main(798)
[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/util_sock.c:get_peer_addr(1150)
  getpeername failed. Error was Transport endpoint is not
connected
[2005/05/11 21:01:23, 0] lib/util_sock.c:write_socket_data(430)
  write_socket_data: write failure. Error = Connection reset by
peer
[2005/05/11 21:01:23, 0] lib/util_sock.c:write_socket(455)
  write_socket: Error writing 5 bytes to socket 30: ERRNO =
Connection reset by peer
[2005/05/11 21:01:23, 0] lib/util_sock.c:send_smb(647)
  Error writing 5 bytes to client. -1. (Connection reset by peer)
[2005/05/11 21:23:14, 0] smbd/server.c:main(798)

--
|------------------------+--------------------------------------|
| Axel Reinhold          | Fax:   +49-9287-8244                 |
| Franz-Heinrich-Str. 20 | eMail: axel@freakout.de              |
| 95100 Selb             | http://www.freakout.de               |
| Germany          | Please do not send more than 100 kilobytes |
|------------------+--------------------------------------------|
| Fingerprint: 8D EF 9F 22 DF 9A 9B 68  E5 8C 12 C7 8D 6A 97 4E |
|---------------------------------------------------------------|
| Legal Warning: Do NOT send unsolicited commercial email to me |
