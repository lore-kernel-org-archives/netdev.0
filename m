From: Joe Perches <joe@perches.com>
Subject: [next][pull request] isdn: Whitespace style reformatting
Date: Sun, 19 Feb 2012 20:38:14 -0800
Message-ID: <1329712694.30026.42.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57554 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751412Ab2BTEiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Feb 2012 23:38:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Karsten.

I've done a quite large cleanup to drivers/isdn with the
intent of improving the message logging style in the near
future.

The style in isdn is a bit scattered, so I used emacs and
some local scripts (and some typing) to reset the base
style to a more current kernel style conformant one.

Basically, it's a per-line oriented change such that no
new lines are added or code movement across lines is done.

spaces are added after commas where appropriate, pointers
are more properly formatted, (type* foo becomes type *foo),
assignments and tests use a single style, spaces have turned
into tabs where appropriate for indentation, etc. 

I built it pre and post x86 allyesconfig with no detected
change in objdump -d or size from the original to this
modified style source..

It's quite large, so instead of posting it, here's a git
tree (with next-20120217 as the base) with a single commit.

More than half of the changes are to a single large file:
drivers/isdn/hardware.eicon/message.c
It didn't use tabs for indentation, so basically the whole
thing got modified.

checkpatch warnings, especially the long line one, have
been ignored.  It's quite a bit more like what passes
for the current kernel coding style though.

The following changes since commit 8ac57b29bb947f00cce7c9736589af8ca74d0fa4:

  Add linux-next specific files for 20120217 (2012-02-17 16:41:11 +1100)

are available in the git repository at:
  git://repo.or.cz/linux-2.6/trivial-mods.git 20120219_isdn

Joe Perches (1):
      isdn: whitespace coding style cleanup

 drivers/isdn/act2000/act2000.h              |   28 +-
 drivers/isdn/act2000/act2000_isa.c          |  394 +-
 drivers/isdn/act2000/act2000_isa.h          |   16 +-
 drivers/isdn/act2000/capi.c                 |  998 +-
 drivers/isdn/act2000/capi.h                 |   50 +-
 drivers/isdn/act2000/module.c               |  800 +-
 drivers/isdn/capi/capi.c                    |  168 +-
 drivers/isdn/capi/capidrv.c                 |  924 +-
 drivers/isdn/capi/capidrv.h                 |   42 +-
 drivers/isdn/capi/capilib.c                 |   16 +-
 drivers/isdn/capi/capiutil.c                |  626 +-
 drivers/isdn/capi/kcapi.c                   |  112 +-
 drivers/isdn/capi/kcapi.h                   |   11 +-
 drivers/isdn/capi/kcapi_proc.c              |   14 +-
 drivers/isdn/divert/divert_init.c           |   75 +-
 drivers/isdn/divert/divert_procfs.c         |  152 +-
 drivers/isdn/divert/isdn_divert.c           | 1475 +-
 drivers/isdn/divert/isdn_divert.h           |  116 +-
 drivers/isdn/gigaset/asyncdata.c            |    2 +-
 drivers/isdn/gigaset/bas-gigaset.c          |   34 +-
 drivers/isdn/gigaset/capi.c                 |  146 +-
 drivers/isdn/gigaset/ev-layer.c             |  326 +-
 drivers/isdn/gigaset/gigaset.h              |   28 +-
 drivers/isdn/gigaset/i4l.c                  |    4 +-
 drivers/isdn/gigaset/interface.c            |   12 +-
 drivers/isdn/gigaset/isocdata.c             |  192 +-
 drivers/isdn/gigaset/proc.c                 |    2 +-
 drivers/isdn/gigaset/ser-gigaset.c          |    6 +-
 drivers/isdn/gigaset/usb-gigaset.c          |    8 +-
 drivers/isdn/hardware/avm/avm_cs.c          |  134 +-
 drivers/isdn/hardware/avm/avmcard.h         |  282 +-
 drivers/isdn/hardware/avm/b1.c              |  178 +-
 drivers/isdn/hardware/avm/b1dma.c           |  154 +-
 drivers/isdn/hardware/avm/b1isa.c           |   18 +-
 drivers/isdn/hardware/avm/b1pci.c           |   44 +-
 drivers/isdn/hardware/avm/b1pcmcia.c        |   28 +-
 drivers/isdn/hardware/avm/c4.c              |  206 +-
 drivers/isdn/hardware/avm/t1isa.c           |   50 +-
 drivers/isdn/hardware/avm/t1pci.c           |   32 +-
 drivers/isdn/hardware/eicon/capi20.h        |  514 +-
 drivers/isdn/hardware/eicon/capidtmf.c      | 1094 +-
 drivers/isdn/hardware/eicon/capidtmf.h      |   78 +-
 drivers/isdn/hardware/eicon/capifunc.c      |  218 +-
 drivers/isdn/hardware/eicon/capifunc.h      |    4 +-
 drivers/isdn/hardware/eicon/capimain.c      |   10 +-
 drivers/isdn/hardware/eicon/cardtype.h      | 1476 +-
 drivers/isdn/hardware/eicon/cp_vers.h       |   32 +-
 drivers/isdn/hardware/eicon/dadapter.c      |  576 +-
 drivers/isdn/hardware/eicon/dadapter.h      |   36 +-
 drivers/isdn/hardware/eicon/debug.c         | 3517 ++--
 drivers/isdn/hardware/eicon/debug_if.h      |   82 +-
 drivers/isdn/hardware/eicon/debuglib.c      |  176 +-
 drivers/isdn/hardware/eicon/debuglib.h      |  272 +-
 drivers/isdn/hardware/eicon/dfifo.h         |   50 +-
 drivers/isdn/hardware/eicon/di.c            | 1430 +-
 drivers/isdn/hardware/eicon/di.h            |  156 +-
 drivers/isdn/hardware/eicon/di_dbg.h        |   34 +-
 drivers/isdn/hardware/eicon/di_defs.h       |  144 +-
 drivers/isdn/hardware/eicon/did_vers.h      |   32 +-
 drivers/isdn/hardware/eicon/diddfunc.c      |   22 +-
 drivers/isdn/hardware/eicon/diva.c          |  158 +-
 drivers/isdn/hardware/eicon/diva_didd.c     |   16 +-
 drivers/isdn/hardware/eicon/diva_dma.c      |  116 +-
 drivers/isdn/hardware/eicon/diva_dma.h      |   62 +-
 drivers/isdn/hardware/eicon/diva_pci.h      |    6 +-
 drivers/isdn/hardware/eicon/divacapi.h      |  612 +-
 drivers/isdn/hardware/eicon/divamnt.c       |   15 +-
 drivers/isdn/hardware/eicon/divasfunc.c     |   34 +-
 drivers/isdn/hardware/eicon/divasi.c        |   56 +-
 drivers/isdn/hardware/eicon/divasmain.c     |  118 +-
 drivers/isdn/hardware/eicon/divasproc.c     |   58 +-
 drivers/isdn/hardware/eicon/divasync.h      |  562 +-
 drivers/isdn/hardware/eicon/dqueue.c        |   14 +-
 drivers/isdn/hardware/eicon/dqueue.h        |   14 +-
 drivers/isdn/hardware/eicon/dsp_defs.h      |  256 +-
 drivers/isdn/hardware/eicon/dsp_tst.h       |    8 +-
 drivers/isdn/hardware/eicon/dspdids.h       |   30 +-
 drivers/isdn/hardware/eicon/dsrv4bri.h      |   34 +-
 drivers/isdn/hardware/eicon/dsrv_bri.h      |   44 +-
 drivers/isdn/hardware/eicon/dsrv_pri.h      |   46 +-
 drivers/isdn/hardware/eicon/entity.h        |   12 +-
 drivers/isdn/hardware/eicon/helpers.h       |   68 +-
 drivers/isdn/hardware/eicon/idifunc.c       |   22 +-
 drivers/isdn/hardware/eicon/io.c            | 1412 +-
 drivers/isdn/hardware/eicon/io.h            |  514 +-
 drivers/isdn/hardware/eicon/istream.c       |  352 +-
 drivers/isdn/hardware/eicon/kst_ifc.h       |  227 +-
 drivers/isdn/hardware/eicon/maintidi.c      | 2265 ++--
 drivers/isdn/hardware/eicon/maintidi.h      |  105 +-
 drivers/isdn/hardware/eicon/man_defs.h      |   36 +-
 drivers/isdn/hardware/eicon/mdm_msg.h       |   72 +-
 drivers/isdn/hardware/eicon/message.c       |28300 +++++++++++++-------------
 drivers/isdn/hardware/eicon/mi_pc.h         |   86 +-
 drivers/isdn/hardware/eicon/mntfunc.c       |  184 +-
 drivers/isdn/hardware/eicon/os_4bri.c       |  352 +-
 drivers/isdn/hardware/eicon/os_4bri.h       |    2 +-
 drivers/isdn/hardware/eicon/os_bri.c        |  262 +-
 drivers/isdn/hardware/eicon/os_bri.h        |    2 +-
 drivers/isdn/hardware/eicon/os_capi.h       |   10 +-
 drivers/isdn/hardware/eicon/os_pri.c        |  390 +-
 drivers/isdn/hardware/eicon/os_pri.h        |    2 +-
 drivers/isdn/hardware/eicon/pc.h            |  268 +-
 drivers/isdn/hardware/eicon/pc_init.h       |   48 +-
 drivers/isdn/hardware/eicon/pc_maint.h      |  158 +-
 drivers/isdn/hardware/eicon/pkmaint.h       |   43 +-
 drivers/isdn/hardware/eicon/platform.h      |  156 +-
 drivers/isdn/hardware/eicon/pr_pc.h         |  116 +-
 drivers/isdn/hardware/eicon/s_4bri.c        |  488 +-
 drivers/isdn/hardware/eicon/s_bri.c         |  288 +-
 drivers/isdn/hardware/eicon/s_pri.c         |  314 +-
 drivers/isdn/hardware/eicon/sdp_hdr.h       |  130 +-
 drivers/isdn/hardware/eicon/um_idi.c        |  222 +-
 drivers/isdn/hardware/eicon/um_idi.h        |    2 +-
 drivers/isdn/hardware/eicon/xdi_adapter.h   |   12 +-
 drivers/isdn/hardware/eicon/xdi_msg.h       |    2 +-
 drivers/isdn/hardware/eicon/xdi_vers.h      |   32 +-
 drivers/isdn/hardware/mISDN/avmfritz.c      |   68 +-
 drivers/isdn/hardware/mISDN/hfc_multi.h     |   47 +-
 drivers/isdn/hardware/mISDN/hfc_multi_8xx.h |   28 +-
 drivers/isdn/hardware/mISDN/hfc_pci.h       |    2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c      | 1264 +-
 drivers/isdn/hardware/mISDN/hfcpci.c        |  348 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c       |  400 +-
 drivers/isdn/hardware/mISDN/hfcsusb.h       |  118 +-
 drivers/isdn/hardware/mISDN/iohelper.h      |  136 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c |   36 +-
 drivers/isdn/hardware/mISDN/mISDNipac.c     |  112 +-
 drivers/isdn/hardware/mISDN/mISDNisar.c     |  206 +-
 drivers/isdn/hardware/mISDN/netjet.c        |   94 +-
 drivers/isdn/hardware/mISDN/netjet.h        |    1 -
 drivers/isdn/hardware/mISDN/speedfax.c      |   22 +-
 drivers/isdn/hardware/mISDN/w6692.c         |   84 +-
 drivers/isdn/hisax/amd7930_fn.c             |  786 +-
 drivers/isdn/hisax/arcofi.c                 |   84 +-
 drivers/isdn/hisax/arcofi.h                 |    2 +-
 drivers/isdn/hisax/asuscom.c                |  100 +-
 drivers/isdn/hisax/avm_a1.c                 |   40 +-
 drivers/isdn/hisax/avm_a1p.c                |  128 +-
 drivers/isdn/hisax/avm_pci.c                |  290 +-
 drivers/isdn/hisax/avma1_cs.c               |  124 +-
 drivers/isdn/hisax/bkm_a4t.c                |   92 +-
 drivers/isdn/hisax/bkm_a8.c                 |  180 +-
 drivers/isdn/hisax/bkm_ax.h                 |   78 +-
 drivers/isdn/hisax/callc.c                  | 1066 +-
 drivers/isdn/hisax/config.c                 |  120 +-
 drivers/isdn/hisax/diva.c                   |  296 +-
 drivers/isdn/hisax/elsa.c                   |  474 +-
 drivers/isdn/hisax/elsa_cs.c                |  164 +-
 drivers/isdn/hisax/elsa_ser.c               |  170 +-
 drivers/isdn/hisax/enternow_pci.c           |  170 +-
 drivers/isdn/hisax/fsm.c                    |   38 +-
 drivers/isdn/hisax/fsm.h                    |    4 +-
 drivers/isdn/hisax/gazel.c                  |  518 +-
 drivers/isdn/hisax/hfc4s8s_l1.c             |  648 +-
 drivers/isdn/hisax/hfc4s8s_l1.h             |    8 +-
 drivers/isdn/hisax/hfc_2bds0.c              |  466 +-
 drivers/isdn/hisax/hfc_2bds0.h              |   28 +-
 drivers/isdn/hisax/hfc_2bs0.c               |  284 +-
 drivers/isdn/hisax/hfc_2bs0.h               |    6 +-
 drivers/isdn/hisax/hfc_pci.c                |  712 +-
 drivers/isdn/hisax/hfc_pci.h                |   96 +-
 drivers/isdn/hisax/hfc_sx.c                 | 1112 +-
 drivers/isdn/hisax/hfc_sx.h                 |   30 +-
 drivers/isdn/hisax/hfc_usb.c                |  586 +-
 drivers/isdn/hisax/hfc_usb.h                |    8 +-
 drivers/isdn/hisax/hfcscard.c               |   88 +-
 drivers/isdn/hisax/hisax.h                  |  166 +-
 drivers/isdn/hisax/hisax_cfg.h              |    6 +-
 drivers/isdn/hisax/hisax_debug.h            |   42 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c         |   88 +-
 drivers/isdn/hisax/hisax_fcpcipnp.h         |    3 +-
 drivers/isdn/hisax/hisax_if.h               |    4 +-
 drivers/isdn/hisax/hisax_isac.c             |   42 +-
 drivers/isdn/hisax/hscx.c                   |  136 +-
 drivers/isdn/hisax/hscx.h                   |    2 +-
 drivers/isdn/hisax/hscx_irq.c               |   18 +-
 drivers/isdn/hisax/icc.c                    |  314 +-
 drivers/isdn/hisax/icc.h                    |    6 +-
 drivers/isdn/hisax/ipac.h                   |    2 +-
 drivers/isdn/hisax/ipacx.c                  |  673 +-
 drivers/isdn/hisax/isac.c                   |  320 +-
 drivers/isdn/hisax/isac.h                   |    2 +-
 drivers/isdn/hisax/isar.c                   | 1750 +-
 drivers/isdn/hisax/isar.h                   |   12 +-
 drivers/isdn/hisax/isdnl1.c                 |  256 +-
 drivers/isdn/hisax/isdnl2.c                 |  338 +-
 drivers/isdn/hisax/isdnl2.h                 |    1 -
 drivers/isdn/hisax/isdnl3.c                 |  170 +-
 drivers/isdn/hisax/isdnl3.h                 |    1 -
 drivers/isdn/hisax/isurf.c                  |  104 +-
 drivers/isdn/hisax/ix1_micro.c              |   94 +-
 drivers/isdn/hisax/jade.c                   |  209 +-
 drivers/isdn/hisax/jade.h                   |  156 +-
 drivers/isdn/hisax/jade_irq.c               |   40 +-
 drivers/isdn/hisax/l3_1tr6.c                |  196 +-
 drivers/isdn/hisax/l3dss1.c                 | 1870 +-
 drivers/isdn/hisax/l3dss1.h                 |   20 +-
 drivers/isdn/hisax/l3ni1.c                  | 1834 +-
 drivers/isdn/hisax/l3ni1.h                  |   28 +-
 drivers/isdn/hisax/lmgr.c                   |   28 +-
 drivers/isdn/hisax/mic.c                    |   62 +-
 drivers/isdn/hisax/netjet.c                 |  585 +-
 drivers/isdn/hisax/netjet.h                 |    5 +-
 drivers/isdn/hisax/niccy.c                  |   78 +-
 drivers/isdn/hisax/nj_s.c                   |   90 +-
 drivers/isdn/hisax/nj_u.c                   |   84 +-
 drivers/isdn/hisax/q931.c                   |  240 +-
 drivers/isdn/hisax/s0box.c                  |  126 +-
 drivers/isdn/hisax/saphir.c                 |  114 +-
 drivers/isdn/hisax/sedlbauer.c              |  302 +-
 drivers/isdn/hisax/sedlbauer_cs.c           |  176 +-
 drivers/isdn/hisax/sportster.c              |  118 +-
 drivers/isdn/hisax/st5481.h                 |   86 +-
 drivers/isdn/hisax/st5481_b.c               |  104 +-
 drivers/isdn/hisax/st5481_d.c               |  192 +-
 drivers/isdn/hisax/st5481_init.c            |   32 +-
 drivers/isdn/hisax/st5481_usb.c             |  267 +-
 drivers/isdn/hisax/tei.c                    |   72 +-
 drivers/isdn/hisax/teleint.c                |  122 +-
 drivers/isdn/hisax/teles0.c                 |  122 +-
 drivers/isdn/hisax/teles3.c                 |  148 +-
 drivers/isdn/hisax/teles_cs.c               |  134 +-
 drivers/isdn/hisax/telespci.c               |   70 +-
 drivers/isdn/hisax/w6692.c                  |  410 +-
 drivers/isdn/hisax/w6692.h                  |   10 +-
 drivers/isdn/hysdn/boardergo.c              |   28 +-
 drivers/isdn/hysdn/boardergo.h              |   30 +-
 drivers/isdn/hysdn/hycapi.c                 |  364 +-
 drivers/isdn/hysdn/hysdn_boot.c             |  302 +-
 drivers/isdn/hysdn/hysdn_defs.h             |   30 +-
 drivers/isdn/hysdn/hysdn_init.c             |    4 +-
 drivers/isdn/hysdn/hysdn_net.c              |   20 +-
 drivers/isdn/hysdn/hysdn_pof.h              |   24 +-
 drivers/isdn/hysdn/hysdn_procconf.c         |   10 +-
 drivers/isdn/hysdn/hysdn_proclog.c          |   26 +-
 drivers/isdn/hysdn/hysdn_sched.c            |   52 +-
 drivers/isdn/hysdn/ince1pc.h                |   68 +-
 drivers/isdn/i4l/isdn_audio.c               |  126 +-
 drivers/isdn/i4l/isdn_bsdcomp.c             |  364 +-
 drivers/isdn/i4l/isdn_common.c              | 1486 +-
 drivers/isdn/i4l/isdn_common.h              |   18 +-
 drivers/isdn/i4l/isdn_concap.c              |   36 +-
 drivers/isdn/i4l/isdn_concap.h              |    4 +-
 drivers/isdn/i4l/isdn_net.c                 | 1488 +-
 drivers/isdn/i4l/isdn_net.h                 |   11 +-
 drivers/isdn/i4l/isdn_ppp.c                 | 1420 +-
 drivers/isdn/i4l/isdn_ppp.h                 |    2 -
 drivers/isdn/i4l/isdn_tty.c                 | 2418 ++--
 drivers/isdn/i4l/isdn_tty.h                 |   10 +-
 drivers/isdn/i4l/isdn_ttyfax.c              | 1092 +-
 drivers/isdn/i4l/isdn_ttyfax.h              |    1 -
 drivers/isdn/i4l/isdn_v110.c                |  294 +-
 drivers/isdn/i4l/isdn_v110.h                |    8 +-
 drivers/isdn/i4l/isdn_x25iface.c            |  226 +-
 drivers/isdn/i4l/isdn_x25iface.h            |   16 +-
 drivers/isdn/i4l/isdnhdlc.c                 |   54 +-
 drivers/isdn/icn/icn.c                      |  800 +-
 drivers/isdn/icn/icn.h                      |   22 +-
 drivers/isdn/isdnloop/isdnloop.c            |  958 +-
 drivers/isdn/isdnloop/isdnloop.h            |    4 +-
 drivers/isdn/mISDN/clock.c                  |   23 +-
 drivers/isdn/mISDN/core.c                   |   35 +-
 drivers/isdn/mISDN/core.h                   |    8 +-
 drivers/isdn/mISDN/dsp.h                    |   21 +-
 drivers/isdn/mISDN/dsp_audio.c              |    3 +-
 drivers/isdn/mISDN/dsp_biquad.h             |    2 +-
 drivers/isdn/mISDN/dsp_blowfish.c           |   16 +-
 drivers/isdn/mISDN/dsp_cmx.c                |  998 +-
 drivers/isdn/mISDN/dsp_core.c               |  171 +-
 drivers/isdn/mISDN/dsp_dtmf.c               |   54 +-
 drivers/isdn/mISDN/dsp_ecdis.h              |   22 +-
 drivers/isdn/mISDN/dsp_hwec.c               |   11 +-
 drivers/isdn/mISDN/dsp_hwec.h               |    1 -
 drivers/isdn/mISDN/dsp_pipeline.c           |   56 +-
 drivers/isdn/mISDN/dsp_tones.c              |  159 +-
 drivers/isdn/mISDN/fsm.c                    |   42 +-
 drivers/isdn/mISDN/hwchannel.c              |   22 +-
 drivers/isdn/mISDN/l1oip.h                  |   21 +-
 drivers/isdn/mISDN/l1oip_codec.c            |   24 +-
 drivers/isdn/mISDN/l1oip_core.c             |  505 +-
 drivers/isdn/mISDN/layer1.c                 |   14 +-
 drivers/isdn/mISDN/layer1.h                 |    1 -
 drivers/isdn/mISDN/layer2.c                 |   95 +-
 drivers/isdn/mISDN/layer2.h                 |   10 +-
 drivers/isdn/mISDN/socket.c                 |   87 +-
 drivers/isdn/mISDN/stack.c                  |  124 +-
 drivers/isdn/mISDN/tei.c                    |  102 +-
 drivers/isdn/mISDN/timerdev.c               |   12 +-
 drivers/isdn/pcbit/callbacks.c              |  303 +-
 drivers/isdn/pcbit/callbacks.h              |   28 +-
 drivers/isdn/pcbit/capi.c                   |  585 +-
 drivers/isdn/pcbit/capi.h                   |   46 +-
 drivers/isdn/pcbit/drv.c                    |  248 +-
 drivers/isdn/pcbit/edss1.c                  |  414 +-
 drivers/isdn/pcbit/edss1.h                  |   13 +-
 drivers/isdn/pcbit/layer2.c                 |   36 +-
 drivers/isdn/pcbit/layer2.h                 |  263 +-
 drivers/isdn/pcbit/module.c                 |   31 +-
 drivers/isdn/pcbit/pcbit.h                  |   28 +-
 drivers/isdn/sc/card.h                      |    2 +-
 drivers/isdn/sc/command.c                   |  128 +-
 drivers/isdn/sc/event.c                     |   24 +-
 drivers/isdn/sc/hardware.h                  |    2 +-
 drivers/isdn/sc/init.c                      |  122 +-
 drivers/isdn/sc/interrupt.c                 |  142 +-
 drivers/isdn/sc/ioctl.c                     |  210 +-
 drivers/isdn/sc/message.c                   |  122 +-
 drivers/isdn/sc/message.h                   |   18 +-
 drivers/isdn/sc/packet.c                    |  119 +-
 drivers/isdn/sc/scioc.h                     |    5 +-
 drivers/isdn/sc/shmem.c                     |   52 +-
 drivers/isdn/sc/timer.c                     |   21 +-
 312 files changed, 49516 insertions(+), 49612 deletions(-)
