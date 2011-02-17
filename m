From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [RFC, PATCH 1/4] net: sh_eth: modify the definitions of register
Date: Thu, 17 Feb 2011 15:51:35 +0900
Message-ID: <4D5CC577.5010108@renesas.com>
References: <4D5A67CC.80107@renesas.com>
 <AANLkTimvaLOuBXcqJ=co1LakTxJqGEUQC3Cif+wBoJhm@mail.gmail.com>
 <AANLkTikxYtG620D4z09k15v7=r5CZ7xCcDWenbJmM_sP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <AANLkTikxYtG620D4z09k15v7=r5CZ7xCcDWenbJmM_sP@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/02/17 9:56, Nobuhiro Iwamatsu wrote:
> 2011/2/17 Nobuhiro Iwamatsu <iwamatsu@nigauri.org>:
>>> +static const u16 *sh_eth_get_register_offset(int register_type)
>>> +{
>>> +       const u16 *reg_offset = NULL;
>>> +
>>> +       switch (register_type) {
>>> +       case SH_ETH_REG_GIGABIT:
>>> +               reg_offset = sh_eth_offset_gigabit;
>>> +               break;
>>> +       case SH_ETH_REG_FAST_SH4:
>>> +               reg_offset = sh_eth_offset_fast_sh4;
>>> +               break;
>>> +       case SH_ETH_REG_FAST_SH3_SH2:
>>> +               reg_offset = sh_eth_offset_fast_sh3_sh2;
>>> +               break;
>>> +       case SH_ETH_REG_DEFAULT:
>>> +#if defined(CONFIG_CPU_SUBTYPE_SH7763)
>>> +               reg_offset = sh_eth_offset_gigabit;
>>> +#elif defined(CONFIG_CPU_SH4)
>>> +               reg_offset = sh_eth_offset_fast_sh4;
>>> +#else
>>> +               reg_offset = sh_eth_offset_fast_sh3_sh2;
>>> +#endif
>>> +               break;
>>> +       default:
>>> +               printk(KERN_ERR "Unknown register type (%d)\n", register_type);
>>> +               break;
>>> +       }
>>> +
>>> +       return reg_offset;
>>> +}
>>> +
>>
>> Is the handling of SH_ETH_REG_DEFAULT necessary?
Thank you for your review!
No, it isn't necessary. I will remove it and I will add NULL checking of mdp->reg_offset.

Best regards,
Yoshihiro Shimoda
