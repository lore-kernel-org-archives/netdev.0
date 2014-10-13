From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: vxlan gro problem ?
Date: Mon, 13 Oct 2014 22:56:44 +0200
Message-ID: <CAJ3xEMiRFEzR0PGDvGty280E97raHzMwE9jVruLzxHaFXqqYYg@mail.gmail.com>
References: <5434FA02.8070608@huawei.com>
	<543ADBA3.5030305@mellanox.com>
	<543B97F0.6040603@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>, qinchuanyu@huawei.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	lichunhe@huawei.com, wangfakai@huawei.com, liuyongan@huawei.com
To: yinpeijun <yinpeijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <543B97F0.6040603@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 13, 2014 at 11:14 AM, yinpeijun <yinpeijun@huawei.com> wrote:
> On 2014/10/13 3:50, Or Gerlitz wrote:
> my test environment use mellanox ConnectX-3 Pro nic ,  as I know the nic support Rx  checksum offload.  but I am not confirm if should  I  do some special configure?
> or the nic driver or firmware need update  ?  also , I have used redhat7.0 ovs vxlan to test with the similar configure as before, but there is also no improvement .

The NIC (HW model and firmware) look just fine. As it seems now, this
boils down to get the RHEL7 inbox mlx4 driver to work properly on your
setup, something which goes a bit beyond the interest of the upstream
mailing lists...

Or.

>
> the nic infomation:
>
> 04:00.0 Ethernet controller: Mellanox Technologies MT27520 Family [ConnectX-3 Pro]
>
> root@localhost:~# ethtool -i eth4
> driver: mlx4_en
> version: 2.0(Dec 2011)
> firmware-version:  2.31.5050
> bus-info: 0000:04:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: no
> supports-register-dump: no
> supports-priv-flags: yes
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
