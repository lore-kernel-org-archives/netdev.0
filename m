From: David Woodhouse <dwmw2@infradead.org>
Subject: SCTP sockopt discrepancy between 2.4 and 2.6.
Date: Mon, 02 Feb 2004 18:43:03 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075747382.786.366.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, marcelo.tosatti@cyclades.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 2.4 and 2.6 SCTP code have _different_ values for the SCTP_*
sockopts. The 2.4 version claims to implement
draft-ietf-tsvwg-sctpsocket-04.txt while the 2.6 version implements
draft-ietf-tsvwg-sctpsocket-07.txt.

This means that tools compiled with the current libraries and header
files cannot work on the 2.4 kernel.

Am I missing something -- like perhaps the existence of a patch to
update the 2.4 kernel -- or is the SCTP implementation in 2.4 no longer
being maintained, and no longer compatible with 2.6 and its userspace?

-- 
dwmw2
