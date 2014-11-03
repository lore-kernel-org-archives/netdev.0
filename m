From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] uapi: resort Kbuild entries
Date: Mon, 3 Nov 2014 12:42:34 -0800
Message-ID: <20141103124234.77377274@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Greg KH <gregkh@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36557 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbaKCUmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:42:47 -0500
Received: by mail-pa0-f50.google.com with SMTP id eu11so12987762pac.9
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 12:42:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The entries in the Kbuild files are incorrectly sorted.
Matters for aesthetics only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Patch against -net tree since that is where my last change was.

--- a/include/uapi/linux/Kbuild	2014-11-02 11:24:32.304658688 -0800
+++ b/include/uapi/linux/Kbuild	2014-11-02 11:27:09.017509917 -0800
@@ -37,27 +37,27 @@ header-y += aio_abi.h
 header-y += apm_bios.h
 header-y += arcfb.h
 header-y += atalk.h
-header-y += atm.h
-header-y += atm_eni.h
-header-y += atm_he.h
-header-y += atm_idt77105.h
-header-y += atm_nicstar.h
-header-y += atm_tcp.h
-header-y += atm_zatm.h
 header-y += atmapi.h
 header-y += atmarp.h
 header-y += atmbr2684.h
 header-y += atmclip.h
 header-y += atmdev.h
+header-y += atm_eni.h
+header-y += atm.h
+header-y += atm_he.h
+header-y += atm_idt77105.h
 header-y += atmioc.h
 header-y += atmlec.h
 header-y += atmmpc.h
+header-y += atm_nicstar.h
 header-y += atmppp.h
 header-y += atmsap.h
 header-y += atmsvc.h
+header-y += atm_tcp.h
+header-y += atm_zatm.h
 header-y += audit.h
-header-y += auto_fs.h
 header-y += auto_fs4.h
+header-y += auto_fs.h
 header-y += auxvec.h
 header-y += ax25.h
 header-y += b1lli.h
@@ -67,8 +67,8 @@ header-y += bfs_fs.h
 header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
-header-y += bpf.h
 header-y += bpf_common.h
+header-y += bpf.h
 header-y += bpqether.h
 header-y += bsg.h
 header-y += btrfs.h
@@ -93,21 +93,21 @@ header-y += cyclades.h
 header-y += cycx_cfm.h
 header-y += dcbnl.h
 header-y += dccp.h
-header-y += dlm.h
+header-y += dlmconstants.h
 header-y += dlm_device.h
+header-y += dlm.h
 header-y += dlm_netlink.h
 header-y += dlm_plock.h
-header-y += dlmconstants.h
 header-y += dm-ioctl.h
 header-y += dm-log-userspace.h
 header-y += dn.h
 header-y += dqblk_xfs.h
 header-y += edd.h
 header-y += efs_fs_sb.h
+header-y += elfcore.h
 header-y += elf-em.h
 header-y += elf-fdpic.h
 header-y += elf.h
-header-y += elfcore.h
 header-y += errno.h
 header-y += errqueue.h
 header-y += ethtool.h
@@ -131,15 +131,15 @@ header-y += fsl_hypervisor.h
 header-y += fuse.h
 header-y += futex.h
 header-y += gameport.h
-header-y += gen_stats.h
 header-y += genetlink.h
+header-y += gen_stats.h
 header-y += gfs2_ondisk.h
 header-y += gigaset_dev.h
-header-y += hdlc.h
 header-y += hdlcdrv.h
+header-y += hdlc.h
 header-y += hdreg.h
-header-y += hid.h
 header-y += hiddev.h
+header-y += hid.h
 header-y += hidraw.h
 header-y += hpet.h
 header-y += hsr_netlink.h
@@ -151,7 +151,6 @@ header-y += i2o-dev.h
 header-y += i8k.h
 header-y += icmp.h
 header-y += icmpv6.h
-header-y += if.h
 header-y += if_addr.h
 header-y += if_addrlabel.h
 header-y += if_alg.h
@@ -165,6 +164,7 @@ header-y += if_ether.h
 header-y += if_fc.h
 header-y += if_fddi.h
 header-y += if_frad.h
+header-y += if.h
 header-y += if_hippi.h
 header-y += if_infiniband.h
 header-y += if_link.h
@@ -182,40 +182,40 @@ header-y += if_tunnel.h
 header-y += if_vlan.h
 header-y += if_x25.h
 header-y += igmp.h
-header-y += in.h
 header-y += in6.h
-header-y += in_route.h
 header-y += inet_diag.h
+header-y += in.h
 header-y += inotify.h
 header-y += input.h
+header-y += in_route.h
 header-y += ioctl.h
-header-y += ip.h
 header-y += ip6_tunnel.h
-header-y += ip_vs.h
 header-y += ipc.h
+header-y += ip.h
 header-y += ipmi.h
 header-y += ipmi_msgdefs.h
 header-y += ipsec.h
 header-y += ipv6.h
 header-y += ipv6_route.h
+header-y += ip_vs.h
 header-y += ipx.h
 header-y += irda.h
 header-y += irqnr.h
-header-y += isdn.h
 header-y += isdn_divertif.h
-header-y += isdn_ppp.h
+header-y += isdn.h
 header-y += isdnif.h
+header-y += isdn_ppp.h
 header-y += iso_fs.h
-header-y += ivtv.h
 header-y += ivtvfb.h
+header-y += ivtv.h
 header-y += ixjuser.h
 header-y += jffs2.h
 header-y += joystick.h
-header-y += kd.h
 header-y += kdev_t.h
-header-y += kernel-page-flags.h
-header-y += kernel.h
+header-y += kd.h
 header-y += kernelcapi.h
+header-y += kernel.h
+header-y += kernel-page-flags.h
 header-y += kexec.h
 header-y += keyboard.h
 header-y += keyctl.h
@@ -231,6 +231,7 @@ ifneq ($(wildcard $(srctree)/arch/$(SRCA
 header-y += kvm_para.h
 endif
 
+header-y += hw_breakpoint.h
 header-y += l2tp.h
 header-y += libc-compat.h
 header-y += limits.h
@@ -255,43 +256,43 @@ header-y += mman.h
 header-y += mmtimer.h
 header-y += mpls.h
 header-y += mqueue.h
-header-y += mroute.h
 header-y += mroute6.h
+header-y += mroute.h
 header-y += msdos_fs.h
 header-y += msg.h
 header-y += mtio.h
-header-y += n_r3964.h
 header-y += nbd.h
-header-y += ncp.h
 header-y += ncp_fs.h
+header-y += ncp.h
 header-y += ncp_mount.h
 header-y += ncp_no.h
 header-y += neighbour.h
-header-y += net.h
-header-y += net_dropmon.h
-header-y += net_tstamp.h
 header-y += netconf.h
 header-y += netdevice.h
-header-y += netlink_diag.h
-header-y += netfilter.h
+header-y += net_dropmon.h
 header-y += netfilter_arp.h
 header-y += netfilter_bridge.h
 header-y += netfilter_decnet.h
+header-y += netfilter.h
 header-y += netfilter_ipv4.h
 header-y += netfilter_ipv6.h
+header-y += net.h
+header-y += netlink_diag.h
 header-y += netlink.h
 header-y += netrom.h
+header-y += net_tstamp.h
 header-y += nfc.h
-header-y += nfs.h
 header-y += nfs2.h
 header-y += nfs3.h
 header-y += nfs4.h
 header-y += nfs4_mount.h
+header-y += nfsacl.h
 header-y += nfs_fs.h
+header-y += nfs.h
 header-y += nfs_idmap.h
 header-y += nfs_mount.h
-header-y += nfsacl.h
 header-y += nl80211.h
+header-y += n_r3964.h
 header-y += nubus.h
 header-y += nvme.h
 header-y += nvram.h
@@ -311,16 +312,16 @@ header-y += pfkeyv2.h
 header-y += pg.h
 header-y += phantom.h
 header-y += phonet.h
+header-y += pktcdvd.h
 header-y += pkt_cls.h
 header-y += pkt_sched.h
-header-y += pktcdvd.h
 header-y += pmu.h
 header-y += poll.h
 header-y += posix_types.h
 header-y += ppdev.h
 header-y += ppp-comp.h
-header-y += ppp-ioctl.h
 header-y += ppp_defs.h
+header-y += ppp-ioctl.h
 header-y += pps.h
 header-y += prctl.h
 header-y += psci.h
@@ -352,13 +353,13 @@ header-y += seccomp.h
 header-y += securebits.h
 header-y += selinux_netlink.h
 header-y += sem.h
-header-y += serial.h
 header-y += serial_core.h
+header-y += serial.h
 header-y += serial_reg.h
 header-y += serio.h
 header-y += shm.h
-header-y += signal.h
 header-y += signalfd.h
+header-y += signal.h
 header-y += smiapp.h
 header-y += snmp.h
 header-y += sock_diag.h
@@ -367,8 +368,8 @@ header-y += sockios.h
 header-y += som.h
 header-y += sonet.h
 header-y += sonypi.h
-header-y += sound.h
 header-y += soundcard.h
+header-y += sound.h
 header-y += stat.h
 header-y += stddef.h
 header-y += string.h
@@ -387,11 +388,11 @@ header-y += time.h
 header-y += times.h
 header-y += timex.h
 header-y += tiocl.h
-header-y += tipc.h
 header-y += tipc_config.h
+header-y += tipc.h
 header-y += toshiba.h
-header-y += tty.h
 header-y += tty_flags.h
+header-y += tty.h
 header-y += types.h
 header-y += udf_fs_i.h
 header-y += udp.h
@@ -437,6 +438,5 @@ header-y += wireless.h
 header-y += x25.h
 header-y += xattr.h
 header-y += xfrm.h
-header-y += hw_breakpoint.h
 header-y += zorro.h
 header-y += zorro_ids.h
