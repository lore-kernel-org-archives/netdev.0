From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 0/3] [bonding 2.4] final sync 2.4 <-> 2.6
Date: Mon, 15 Sep 2003 11:59:58 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151159.58050.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This small patch set handles the final bonding sync. Except for a small
ipx_hdr() issue, 2.4 code after this set should be identical to 2.6 (with
my latest 2.6 set applied: "propagating master's settings to slaves").

Patch #3 isn't really a bonding patch, but it is needed for the seq_file
patch to work in 2.4 (and the whole point of the code sync is that the same
patches will cleanly apply to both trees).

This set applies on top of 2.4.23-pre4.

The seq_file patch (that will apply to both 2.4 and 2.6) will be following
this set shortly.

patch1: Get rid of MOD_*_USE_COUNT, and use C99 initializers.
patch2: Backport free_netdev().
patch3: Backport PDE().

-- 
Amir
