From: Boaz Harrosh <bharrosh@panasas.com>
Subject: 3c505.c: Does not compile on linus/master  [f362f98]
Date: Mon, 31 Oct 2011 14:12:20 -0700
Message-ID: <4EAF0F34.4070702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Philip Blundell <philb@gnu.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doing an "make ARCH=3Di386 allmodconfig" on  linus/master  [f362f98] gi=
ves me the below
compilation breakage.

(Fedora_15_amd64 machine)

It's probably old news but I thought I'll report it as part of my oblig=
ation
as a Kernel monkey

Cheers
Boaz
----

/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98send_pcb=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:390:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:390:4: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:436:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:435:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98start_receive=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:557:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:557:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98receive_packet=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:629:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:629:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_interrupt=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:667:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:665:5: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:689:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:689:6: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:724:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:723:8: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:729:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:728:9: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:736:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:736:8: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:746:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:746:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:756:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:755:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:766:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:765:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:776:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:775:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:792:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:792:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:800:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:800:7: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:821:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:820:6: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_open=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:854:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:854:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:916:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:916:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:940:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:940:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:962:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:962:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98send_packet=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:992:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:992:4: error: expected =E2=80=98}=E2=80=99 before =E2=80=98=
=2E=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1014:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1014:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1040:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1040:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_timeout=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1057:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1057:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_start_xmit=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1079:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1079:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1088:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1088:4: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1094:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1094:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_get_stats=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1113:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1113:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_close=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1175:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1175:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_set_mc_list=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1219:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1219:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1253:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1253:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_sense=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1289:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1289:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c: In function =E2=80=98elp_autodetect=E2=80=99:
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1355:1: error: expected identifier before string constant
/net/ca-quad-11a-boot/samana/bharrosh/git/loo-ct/drivers/net/ethernet/i=
825xx/3c505.c:1355:3: error: expected =E2=80=98}=E2=80=99 before =E2=80=
=98.=E2=80=99 token
