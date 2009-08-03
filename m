From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Date: Mon, 03 Aug 2009 10:30:01 +0200
Message-ID: <4A76A009.40605@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.syneticon.net ([78.111.66.105]:41981 "EHLO
	mx03.syneticon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbZHCIac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 04:30:32 -0400
Received: from localhost (filter1.syneticon.net [192.168.113.83])
	by mx03.syneticon.net (Postfix) with ESMTP id 143F33601F
	for <netdev@vger.kernel.org>; Mon,  3 Aug 2009 10:30:33 +0200 (CEST)
Received: from mx03.syneticon.net ([192.168.113.84])
	by localhost (mx03.syneticon.net [192.168.113.83]) (amavisd-new, port 10025)
	with ESMTP id yoM-zAuyuQIR for <netdev@vger.kernel.org>;
	Mon,  3 Aug 2009 10:30:30 +0200 (CEST)
Received: from [192.168.10.145] (koln-4db4878a.pool.einsundeins.de [77.180.135.138])
	by mx03.syneticon.net (Postfix) with ESMTPSA
	for <netdev@vger.kernel.org>; Mon,  3 Aug 2009 10:30:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upgrading from 2.6.29.1 to 2.6.30.4, I'm getting these warnings in dmesg.

Let me know if you need more info.

Other than that, the device seems to work stable.

------------[ cut here ]------------
WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Hardware name: Altos G510
Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
Pid: 2222, comm: openvpn Not tainted 2.6.30.4-1 #4
Call Trace:
 [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
 [<4011f04e>] ? warn_slowpath_null+0xa/0xc
 [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
 [<402796a4>] ? sk_free+0x10/0xa7
 [<402b5964>] ? inet_release+0x3f/0x44
 [<4027751b>] ? sock_release+0x11/0x52
 [<40277575>] ? sock_close+0x19/0x1c
 [<40164026>] ? __fput+0xa6/0x149
 [<40161989>] ? filp_close+0x4e/0x54
 [<401619f5>] ? sys_close+0x66/0x9c
 [<401027c8>] ? sysenter_do_call+0x12/0x26
---[ end trace bdfe445acbab5307 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Hardware name: Altos G510
Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
Pid: 2222, comm: openvpn Tainted: G        W  2.6.30.4-1 #4
Call Trace:
 [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
 [<4011f04e>] ? warn_slowpath_null+0xa/0xc
 [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
 [<402796a4>] ? sk_free+0x10/0xa7
 [<402b5964>] ? inet_release+0x3f/0x44
 [<4027751b>] ? sock_release+0x11/0x52
 [<40277575>] ? sock_close+0x19/0x1c
 [<40164026>] ? __fput+0xa6/0x149
 [<40161989>] ? filp_close+0x4e/0x54
 [<401619f5>] ? sys_close+0x66/0x9c
 [<401027c8>] ? sysenter_do_call+0x12/0x26
---[ end trace bdfe445acbab5308 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Hardware name: Altos G510
Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
Pid: 2222, comm: openvpn Tainted: G        W  2.6.30.4-1 #4
Call Trace:
 [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
 [<4011f04e>] ? warn_slowpath_null+0xa/0xc
 [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
 [<402796a4>] ? sk_free+0x10/0xa7
 [<402b5964>] ? inet_release+0x3f/0x44
 [<4027751b>] ? sock_release+0x11/0x52
 [<40277575>] ? sock_close+0x19/0x1c
 [<40164026>] ? __fput+0xa6/0x149
 [<40161989>] ? filp_close+0x4e/0x54
 [<401619f5>] ? sys_close+0x66/0x9c
 [<401027c8>] ? sysenter_do_call+0x12/0x26
---[ end trace bdfe445acbab5309 ]---



-- 
Tomasz Chmielewski
http://wpkg.org
