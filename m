From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: ICMP breaks TCP connection
Date: Sat, 24 Jul 2004 15:08:19 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407241503470.27814@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

I found that Linux 2.2.16 and 2.4.25 break tcp connection (with no route
to host error) after first attempt when received ICMP packet with type 3
and code 1 (ICMP_UNREACH_HOST).

RFC1122, section 3.2.2.1 says, that the message MUST be interpreted as
hint, not proof of unreachable machine.

Mikulas
