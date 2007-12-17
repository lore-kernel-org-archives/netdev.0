From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG]  lack of  /proc/net/ax25  with  2.6.24-rc5
Date: Mon, 17 Dec 2007 22:56:26 +0100
Message-ID: <200712172256.26699.rjw@sisk.pl>
References: <476303C8.2060507@ccr.jussieu.fr> <20071215101810.GA3143@ami.dom.local> <476595EC.5050103@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:55070 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933804AbXLQVhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 16:37:43 -0500
In-Reply-To: <476595EC.5050103@ccr.jussieu.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 16 of December 2007, Bernard Pidoux wrote:
> With 2.6.24-rc5 there is no /proc/net/ax25

FYI, I've created a Bugzilla entry for this issue at:
http://bugzilla.kernel.org/show_bug.cgi?id=9589

Please add your address to the CC list in there.

Thanks,
Rafael


> Here is an extract from dmesg after boot :
> 
> =======================
> sysctl table check failed: /net/ax25/ax0/ax25_default_mode .3.9.1.2 
> Unknown sysctl binary path
> Pid: 2936, comm: kissattach Not tainted 2.6.24-rc5 #1
>   [<c012ca6a>] set_fail+0x3b/0x43
>   [<c012ce7a>] sysctl_check_table+0x408/0x456
>   [<c012ce8e>] sysctl_check_table+0x41c/0x456
>   [<c012ce8e>] sysctl_check_table+0x41c/0x456
>   [<c02ac64a>] _spin_unlock+0x14/0x1c
>   [<c012ce8e>] sysctl_check_table+0x41c/0x456
>   [<c011e681>] sysctl_set_parent+0x19/0x2a
>   [<c011f55c>] register_sysctl_table+0x45/0x85
>   [<d8be9d26>] ax25_register_sysctl+0x112/0x11c [ax25]
>   [<d8be6c76>] ax25_device_event+0x2e/0x90 [ax25]
>   [<c012c560>] notifier_call_chain+0x2a/0x47
>   [<c012c59f>] raw_notifier_call_chain+0x17/0x1a
>   [<c0259290>] dev_open+0x6f/0x75
>   [<c0257ee7>] dev_change_flags+0x9c/0x148
>   [<c0256ab3>] __dev_get_by_name+0x68/0x73
>   [<c0292307>] devinet_ioctl+0x22e/0x53b
>   [<c0259074>] dev_ioctl+0x472/0x5ba
>   [<c024d4ba>] sock_ioctl+0x1aa/0x1cf
>   [<c024d310>] sock_ioctl+0x0/0x1cf
>   [<c016bc19>] do_ioctl+0x19/0x4c
>   [<c016be40>] vfs_ioctl+0x1f4/0x20b
>   [<c0103d01>] sysenter_past_esp+0x9a/0xa9
>   [<c016be9c>] sys_ioctl+0x45/0x5d
>   [<c0103cc6>] sysenter_past_esp+0x5f/0xa9
>   =======================
> sysctl table check failed: /net/ax25/ax0/backoff_type .3.9.1.3 Unknown 
> sysctl binary path
> (...) truncated
>   =======================
> sysctl table check failed: /net/ax25/ax0/connect_mode .3.9.1.4 Unknown 
> sysctl binary path
> (...)
>   =======================
> sysctl table check failed: /net/ax25/ax0/standard_window_size .3.9.1.5 
> Unknown sysctl binary path
>   =======================
> (...)
> 
> and so on ...
> 
> 
> 
> Bernard Pidoux
> f6bvp@amsat.org
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 



-- 
"Premature optimization is the root of all evil." - Donald Knuth
