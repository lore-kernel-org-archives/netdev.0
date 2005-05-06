From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] various iproute2 patches
Date: Fri, 6 May 2005 18:12:09 +0200
Message-ID: <20050506161209.GG28419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Seems my previous attempt didn't get through the mailinglist,
probably exceeded maximum attachment size.

Patches can be found here:

  http://people.suug.ch/~tgr/iproute2/patches/2.6.12-rc2/

I merged my tree and sorted out all patches covering bits for
the 2.6.12 release.

 ChangeLog                             |   13 
 Makefile                              |    7 
 etc/iproute2/ematch_map               |    5 
 include/linux/ip_mp_alg.h             |   22 +
 include/linux/rtnetlink.h             |   21 -
 include/linux/tc_ematch/tc_em_cmp.h   |   26 +
 include/linux/tc_ematch/tc_em_meta.h  |   69 ++++
 include/linux/tc_ematch/tc_em_nbyte.h |   13 
 include/linux/xfrm.h                  |    5 
 include/utils.h                       |    2 
 ip/iproute.c                          |   32 ++
 tc/Makefile                           |   16 -
 tc/em_cmp.c                           |  188 ++++++++++++
 tc/em_meta.c                          |  524 ++++++++++++++++++++++++++++++++++
 tc/em_nbyte.c                         |  144 +++++++++
 tc/em_u32.c                           |  178 +++++++++++
 tc/emp_ematch.l                       |  143 +++++++++
 tc/emp_ematch.y                       |  102 ++++++
 tc/f_basic.c                          |  146 +++++++++
 tc/m_ematch.c                         |  492 +++++++++++++++++++++++++++++++
 tc/m_ematch.h                         |  177 +++++++++++
 tc/tc.c                               |   19 -
 testsuite/Makefile                    |   36 +-
 testsuite/iproute2/Makefile           |   33 ++
 testsuite/lib/generic.sh              |   88 +++++
 testsuite/tests/cbq.t                 |   10 
 testsuite/tests/cls-testbed.t         |   68 ++++
 testsuite/tests/cls/attrs-testbed.t   |   33 ++
 testsuite/tests/cls/attrs/police.t    |   20 +
 testsuite/tests/cls/route.t           |   24 +
 testsuite/tests/cls/tcindex.t         |   11 
 testsuite/tests/dsmark.t              |   31 ++
 testsuite/tests/policer               |   13 
 testsuite/tests/std-cbq               |   10 
 34 files changed, 2657 insertions(+), 64 deletions(-)


01_iproute2_ematch.diff
  Support for extended matches and basic classifier

02_iproute_ematch_map.diff
  ematch map file

03_iproute2_makefile_fixes.diff
  Fix clean/distclean to delete the bison output

04_iproute2_update_headers.diff
  Update to latest kernel header versions

05_iproute2_testsuite_update.diff
  Update to latest testsuite

06_iproute2_multipath_selection.diff
  IPv4 multipath routing algorithm selection

07_iproute2_cscope_target.diff
  cscope target for Makefile

08_iproute2_batching_fixes.diff
  Fix off-by-one during argument generation
  Assume stdin when no argument is given to -batch

09_iproute2_update_changelog.diff
  Update ChangeLog
