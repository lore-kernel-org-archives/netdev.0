From: David Woodhouse <dwmw2@infradead.org>
Subject: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf with
	nfsroot....
Date: Thu, 19 Feb 2004 14:38:20 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Putting IPv6 before IPv4 in net/Makefile fixes it, letting it IPv6
register its notifiers before the IPv4 ipconfig code brings up the
interface.

Objections?

-- 
dwmw2
