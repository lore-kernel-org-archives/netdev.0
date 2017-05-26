From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH v3 1/2] net: phy: Add Cortina CS4340 driver (fwd)
Date: Fri, 26 May 2017 16:31:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1705261631020.2950@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kbuild-all-JC7UmRfGjtg@public.gmane.org
To: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The u32 values on lines 73 and 79 will not be less than 0.

julia

---------- Forwarded message ----------
Date: Fri, 26 May 2017 19:31:28 +0800
From: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: kbuild-JC7UmRfGjtg@public.gmane.org
Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH v3 1/2] net: phy: Add Cortina CS4340 driver

CC: kbuild-all-JC7UmRfGjtg@public.gmane.org
In-Reply-To: <1495785519-1468-2-git-send-email-bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
TO: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
CC: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC:

Hi Bogdan,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.12-rc2 next-20170526]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Bogdan-Purcareata/net-phy-Add-Cortina-CS4340-driver/20170526-170949
:::::: branch date: 2 hours ago
:::::: commit date: 2 hours ago

>> drivers/net/phy/cortina.c:73:5-11: WARNING: Unsigned expression compared with zero: id_lsb < 0
>> drivers/net/phy/cortina.c:79:5-11: WARNING: Unsigned expression compared with zero: id_msb < 0

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 84281ef4be227acc6a2f638da7a6842f7f55348d
vim +73 drivers/net/phy/cortina.c

84281ef4 Bogdan Purcareata 2017-05-26  67  static int cortina_probe(struct phy_device *phydev)
84281ef4 Bogdan Purcareata 2017-05-26  68  {
84281ef4 Bogdan Purcareata 2017-05-26  69  	u32 phy_id = 0, id_lsb, id_msb;
84281ef4 Bogdan Purcareata 2017-05-26  70
84281ef4 Bogdan Purcareata 2017-05-26  71  	/* Read device id from phy registers. */
84281ef4 Bogdan Purcareata 2017-05-26  72  	id_lsb = cortina_read_reg(phydev, VILLA_GLOBAL_CHIP_ID_LSB);
84281ef4 Bogdan Purcareata 2017-05-26 @73  	if (id_lsb < 0)
84281ef4 Bogdan Purcareata 2017-05-26  74  		return -ENXIO;
84281ef4 Bogdan Purcareata 2017-05-26  75
84281ef4 Bogdan Purcareata 2017-05-26  76  	phy_id = id_lsb << 16;
84281ef4 Bogdan Purcareata 2017-05-26  77
84281ef4 Bogdan Purcareata 2017-05-26  78  	id_msb = cortina_read_reg(phydev, VILLA_GLOBAL_CHIP_ID_MSB);
84281ef4 Bogdan Purcareata 2017-05-26 @79  	if (id_msb < 0)
84281ef4 Bogdan Purcareata 2017-05-26  80  		return -ENXIO;
84281ef4 Bogdan Purcareata 2017-05-26  81
84281ef4 Bogdan Purcareata 2017-05-26  82  	phy_id |= id_msb;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
