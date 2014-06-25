From: Paul Bolle <pebolle@tiscali.nl>
Subject: Documentation: is there a reason to keep
 networking/policy-routing.txt
Date: Wed, 25 Jun 2014 16:47:58 +0200
Message-ID: <1403707678.1960.60.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

0) Documentation/networking/policy-routing.txt was added in v2.1.16.
Since then it has only received spelling fixes. That shows. I'll list
the issues I noticed below. Perhaps this file could be updated, and that
might even be trivial to do. But is that file still relevant? And
besides, why bother to keep documentation that appears to be
unmaintained for 18 years now?

1) RT_CLASS_LOCAL, RT_CLASS_MAIN, and RT_CLASS_DEFAULT: should probably
be RT_TABLE_LOCAL, etc.

2) RTP_ROUTE, RTP_NAT, RTP_MASQUERADE, RTP_DROP, RTP_REJECT, and
RTP_PROHIBIT: cannot be found in the tree.

3) RTRF_LOG, and RTRF_VALVE: ditto.

4) It mentions an iproute command. I'm familiar with route and "ip
route". Fedora doesn't ship an iproute command. Web searches for it are
hard, but it appears to have shipped in (old releases of) Debian.

5) The "IMPORTANT NOTE" about CONFIG_IP_LOCAL_RT_POLICY is obsolete
since v2.1.68.


Paul Bolle

