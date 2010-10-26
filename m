From: Jaswinder Singh <jaswinderlinux@gmail.com>
Subject: Re: ath9k crashing the kernel
Date: Tue, 26 Oct 2010 12:39:38 +0530
Message-ID: <AANLkTikHTgoJyxm80MuXM9oTvCPTFAPM12zVih1RsTfy@mail.gmail.com>
References: <AANLkTim=jD-C4DwDS2=KuQnhPOyP+Cnd-hUTdaZ7Opth@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, ath9k-devel@lists.ath9k.org,
	Linus Torvald
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <AANLkTim=jD-C4DwDS2=KuQnhPOyP+Cnd-hUTdaZ7Opth@mail.gmail.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Oct 26, 2010 at 10:36 AM, Jaswinder Singh
<jaswinderlinux@gmail.com> wrote:
>
> ath9k is crashing the kernel :
>
> [ =A0 21.276554] BUG: spinlock bad magic on CPU#1, NetworkManager/1056
> [ =A0 21.277015] =A0lock: f5be80a8, .magic: 00000000, .owner: <none>/-1,
> .owner_cpu: 0
> [ =A0 21.277015] Pid: 1056, comm: NetworkManager Not tainted 2.6.36-netbo=
ok+ #20
> [ =A0 21.277015] Call Trace:
> [ =A0 21.277015] =A0[<c14767a7>] ? printk+0xf/0x11
> [ =A0 21.277015] =A0[<c117b823>] spin_bug+0x7c/0x87
> [ =A0 21.301365] =A0[<c117b8bd>] do_raw_spin_lock+0x1e/0x125
> [ =A0 21.301365] =A0[<c1478d0a>] ? _raw_spin_unlock_bh+0x1a/0x1c
> [ =A0 21.301365] =A0[<c1478dc3>] _raw_spin_lock_irqsave+0x17/0x1c
> [ =A0 21.318857] =A0[<c1288a74>] ath9k_config+0x255/0x38b
> [ =A0 21.318857] =A0[<c1447bdb>] ieee80211_hw_config+0x10a/0x114
> [ =A0 21.328034] =A0[<c1453545>] ieee80211_do_open+0x3de/0x4cf
> [ =A0 21.328034] =A0[<c1452206>] ? ieee80211_check_concurrent_iface+0x21/=
0x13a
> [ =A0 21.328034] =A0[<c104c470>] ? raw_notifier_call_chain+0xc/0xe
> [ =A0 21.328034] =A0[<c1453691>] ieee80211_open+0x5b/0x5e
> [ =A0 21.328034] =A0[<c13947cf>] __dev_open+0x80/0xa9
> [ =A0 21.328034] =A0[<c13920bb>] __dev_change_flags+0xa1/0x116
> [ =A0 21.328034] =A0[<c1394723>] dev_change_flags+0x13/0x3f
> [ =A0 21.328034] =A0[<c139d568>] do_setlink+0x226/0x507
> [ =A0 21.328034] =A0[<c139d917>] rtnl_setlink+0xce/0xd4
> [ =A0 21.328034] =A0[<c11786d2>] ? copy_to_user+0x3a/0x118
> [ =A0 21.328034] =A0[<c139d849>] ? rtnl_setlink+0x0/0xd4
> [ =A0 21.328034] =A0[<c139df4d>] rtnetlink_rcv_msg+0x17e/0x194
> [ =A0 21.328034] =A0[<c139ddcf>] ? rtnetlink_rcv_msg+0x0/0x194
> [ =A0 21.328034] =A0[<c13a59c4>] netlink_rcv_skb+0x30/0x76
> [ =A0 21.328034] =A0[<c139ddc8>] rtnetlink_rcv+0x1b/0x22
> [ =A0 21.328034] =A0[<c13a5772>] netlink_unicast+0x1aa/0x20b
> [ =A0 21.328034] =A0[<c13a5eac>] netlink_sendmsg+0x22c/0x27a
> [ =A0 21.328034] =A0[<c13862b8>] sock_sendmsg+0xa5/0xbb
> [ =A0 21.328034] =A0[<c13862b8>] ? sock_sendmsg+0xa5/0xbb
> [ =A0 21.328034] =A0[<c138e05b>] ? verify_iovec+0x3e/0x6b
> [ =A0 21.328034] =A0[<c1386ab2>] sys_sendmsg+0x149/0x196
> [ =A0 21.328034] =A0[<c10826f5>] ? unlock_page+0x40/0x43
> [ =A0 21.328034] =A0[<c10952d5>] ? __do_fault+0x367/0x393
> [ =A0 21.328034] =A0[<c1096b8e>] ? handle_mm_fault+0x3bd/0x77a
> [ =A0 21.328034] =A0[<c10b6fb3>] ? destroy_inode+0x1f/0x30
> [ =A0 21.328034] =A0[<c138694e>] ? sys_recvmsg+0x2b/0x46
> [ =A0 21.328034] =A0[<c1387c00>] sys_socketcall+0x146/0x18b
> [ =A0 21.328034] =A0[<c1002850>] sysenter_do_call+0x12/0x26
> [ =A0 21.344846] ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [ =A0 21.487994] atl1c 0000:03:00.0: irq 42 for MSI/MSI-X
> [ =A0 21.543870] ADDRCONF(NETDEV_UP): eth0: link is not ready
>
>
> Linux 2.6.36 f6f94e2ab1 is good
> and
> 229aebb873e2972 is bad
>

After further investigation bad commit is :

3430098ae463e31ab16926ac3eb295368a3ca5d9 is the first bad commit
commit 3430098ae463e31ab16926ac3eb295368a3ca5d9
Author: Felix Fietkau <nbd@openwrt.org>
Date:   Sun Oct 10 18:21:52 2010 +0200

    ath9k: implement channel utilization stats for survey

    Results for the active channel are updated whenever a new survey dump
    is requested, the old data is kept to allow multiple processes to
    make their own channel utilization averages.
    All other channels only contain the data for the last time that the
    hardware was on the channel, i.e. the last scan result or other
    off-channel activity.
    Running a background scan does not clear the data for the active
    channel.

    Signed-off-by: Felix Fietkau <nbd@openwrt.org>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>


Thanks,
--
Jaswinder Singh.
> I am trying to bisect it but I am getting compilation error :
>
> =A0LD =A0 =A0 =A0.tmp_vmlinux1
> drivers/built-in.o: In function `ath_do_set_opmode':
> /home/jaswinder/jaswinder-git/linux-2.6/drivers/net/wireless/ath/ath5k/ba=
se.c:567:
> undefined reference to `ath_opmode_to_string'
> /home/jaswinder/jaswinder-git/linux-2.6/drivers/net/wireless/ath/ath5k/ba=
se.c:568:
> undefined reference to `ath_opmode_to_string'
> make: *** [.tmp_vmlinux1] Error 1
> [jaswinder@ linux-2.6]$
>
