From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] igb: Explicitly select page 0 at initialization
Date: Thu, 24 Nov 2016 13:36:55 +0300
Message-ID: <bf11b668-0ee4-3cfd-405b-43705a6e011e@cogentembedded.com>
References: <1479983568-4383-1-git-send-email-matwey@sai.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, todd.fujinaka@intel.com,
        carolyn.wyborny@intel.com, dchang@suse.com, jcheung@suse.com,
        matwey.kornilov@gmail.com, stable@vger.kernel.org
To: "Matwey V. Kornilov" <matwey@sai.msu.ru>,
        jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479983568-4383-1-git-send-email-matwey@sai.msu.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/24/2016 1:32 PM, Matwey V. Kornilov wrote:

> The functions igb_read_phy_reg_gs40g/igb_write_phy_reg_gs40g (which were
> removed in 2a3cdea) explicitly selected the required page at every phy_reg

    This is not the way to cite a commit -- you need to specify at least 12 
digits and follow them with the commit subject enclosed into ("").

> access. Currently, igb_get_phy_id_82575 relays on the fact that page 0 is
> already selected. The assumption is not fulfilled for my Lex 3I380CW
> motherboard with integrated dual i211 based gigabit ethernet. This leads to igb
> initialization failure and network interfaces are not working:
>
>     igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
>     igb: Copyright (c) 2007-2014 Intel Corporation.
>     igb: probe of 0000:01:00.0 failed with error -2
>     igb: probe of 0000:02:00.0 failed with error -2
>
> In order to fix it, we explicitly select page 0 before first access to phy
> registers.
>
> See also: https://bugzilla.suse.com/show_bug.cgi?id=1009911
> See also: http://www.lex.com.tw/products/pdf/3I380A&3I380CW.pdf
>
> Fixes: 2a3cdea ("igb: Remove GS40G specific defines/functions")

    Again, at least 12 digits.

> Cc: <stable@vger.kernel.org> # 4.5+
> Signed-off-by: Matwey V. Kornilov <matwey@sai.msu.ru>
[...]

MBR, Sergei
