From: Grahame Bowland <grahame@angrygoats.net>
Subject: SIOCGIFADDR and IPv6
Date: Mon, 29 Mar 2004 11:44:20 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1080531859.3435.8.camel@anduril>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hey all

I've noticed that calling SIOCGIFADDR on an IPv6 socket to get the
interface address always returns EINVAL. Would a patch to implement that
feature be accepted?

As far as I can see, it wasn't implemented in the USAGI tree because a
struct ifreq couldn't fit an IPv6 address. However, the current kernel
IPv6 has the struct in6_ifreq to support SIOCSIFADDR, which fixes that
problem.

Cheers
Grahame
