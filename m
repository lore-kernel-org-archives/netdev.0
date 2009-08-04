From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155
	inet_sock_destruct+0x122/0x13a()
Date: Mon, 03 Aug 2009 19:38:01 -0500
Message-ID: <1249346282.6479.5.camel@merlyn>
References: <4A76A009.40605@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tomasz Chmielewski <mangoo@wpkg.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f196.google.com ([209.85.222.196]:45005 "EHLO
	mail-pz0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbZHDApx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 20:45:53 -0400
Received: by pzk34 with SMTP id 34so2681994pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 17:45:53 -0700 (PDT)
In-Reply-To: <4A76A009.40605@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-03 at 10:30 +0200, Tomasz Chmielewski wrote:
> After upgrading from 2.6.29.1 to 2.6.30.4, I'm getting these warnings in dmesg.
> 
> Let me know if you need more info.
> 
> Other than that, the device seems to work stable.
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
> Hardware name: Altos G510
> Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
> Pid: 2222, comm: openvpn Not tainted 2.6.30.4-1 #4
> Call Trace:
>  [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
>  [<4011f04e>] ? warn_slowpath_null+0xa/0xc
>  [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
>  [<402796a4>] ? sk_free+0x10/0xa7
>  [<402b5964>] ? inet_release+0x3f/0x44
>  [<4027751b>] ? sock_release+0x11/0x52
>  [<40277575>] ? sock_close+0x19/0x1c
>  [<40164026>] ? __fput+0xa6/0x149
>  [<40161989>] ? filp_close+0x4e/0x54
>  [<401619f5>] ? sys_close+0x66/0x9c
>  [<401027c8>] ? sysenter_do_call+0x12/0x26
> ---[ end trace bdfe445acbab5307 ]---
> ------------[ cut here ]------------
> WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
> Hardware name: Altos G510
> Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
> Pid: 2222, comm: openvpn Tainted: G        W  2.6.30.4-1 #4
> Call Trace:
>  [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
>  [<4011f04e>] ? warn_slowpath_null+0xa/0xc
>  [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
>  [<402796a4>] ? sk_free+0x10/0xa7
>  [<402b5964>] ? inet_release+0x3f/0x44
>  [<4027751b>] ? sock_release+0x11/0x52
>  [<40277575>] ? sock_close+0x19/0x1c
>  [<40164026>] ? __fput+0xa6/0x149
>  [<40161989>] ? filp_close+0x4e/0x54
>  [<401619f5>] ? sys_close+0x66/0x9c
>  [<401027c8>] ? sysenter_do_call+0x12/0x26
> ---[ end trace bdfe445acbab5308 ]---
> ------------[ cut here ]------------
> WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
> Hardware name: Altos G510
> Modules linked in: nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs tun bitrev crc32 bonding lm75 adm9240 adm1026 hwmon_vid hwmon i2c_piix4 i2c_core dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod e1000 tg3 libphy
> Pid: 2222, comm: openvpn Tainted: G        W  2.6.30.4-1 #4
> Call Trace:
>  [<4011f018>] ? warn_slowpath_common+0x5e/0x8a
>  [<4011f04e>] ? warn_slowpath_null+0xa/0xc
>  [<402b5d64>] ? inet_sock_destruct+0x122/0x13a
>  [<402796a4>] ? sk_free+0x10/0xa7
>  [<402b5964>] ? inet_release+0x3f/0x44
>  [<4027751b>] ? sock_release+0x11/0x52
>  [<40277575>] ? sock_close+0x19/0x1c
>  [<40164026>] ? __fput+0xa6/0x149
>  [<40161989>] ? filp_close+0x4e/0x54
>  [<401619f5>] ? sys_clos+0x66/0x9c
>  [<401027c8>] ? sysenter_do_call+0x12/0x26
> ---[ end trace bdfe445acbab5309 ]---

Thanks for the report, Tomasz.  

There's a good chance e51a67a9c8a2ea5c563f8c2ba6613fe2100ffe67 from the
current mainline will fix this problem.

Dave, Eric's fix might be a candidate for -stable.  The symptom is
usually a WARN, but the impact is significant.

  --  John

