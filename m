From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: RTL8192EE PCIe Wireless Network Adapter crashed with linux-4.13
Date: Thu, 21 Sep 2017 17:49:50 +0300
Message-ID: <871sn09kdt.fsf@kamboji.qca.qualcomm.com>
References: <2WhCEttl4IJtrTB2AkJYmhbsu-kiR_5fU0A_Z7eWW05rbVE5tB86A_ZS8ek_FQFdgaZw1bfx0wFbxOa0Ydjv1T6BzBkIHtaWTbSptcpB_kg=@protonmail.com>
        <e8e75755-f8b4-e122-ea4a-99a691405d38@lwfinger.net>
        <jB0WJNG17mSfKo9m7T26r-b2Gr7mDL4lJ-1cWxeCJ6UCsA4TsxXz4znCLhYY5EASPQciwp1rf_xtwvDR-xzwD-OTApTUFoaVmIvahleDcJk=@protonmail.com>
        <1eb67d2e-dfbc-a2d0-8949-d4336191c07b@lwfinger.net>
        <x1duse6v9TTP8Ta7rsTLlZ8DK0Ej7qq9iapef18K0eYSodmCBmfI_mX3c-3ocbPiGzEgV9weOh25dKWSbU5nIetYkfmmUxaxRpUdYFffRZA=@protonmail.com>
        <35856452-c05c-d116-f91b-0964947ec8ae@lwfinger.net>
        <2_UKRQjXR9_CXy_99R7fqRbs4VDG0hfFCMvvf4ll2BQV5C_zNiPTnHHNtoYstAGy_UF9X85pl4siU7fnXefmqbhlErxR6FqZQfIf0tADKNg=@protonmail.com>
        <5e2a695a-ea26-e0a3-d5eb-cf8135c1349e@lwfinger.net>
        <ZeTD57H3euqWFB5wrD_vYAkdu91l_6Yalbz_mRWtrrb2t17d0cdWOpCaXw33jcPYNKhgqnHbuqHTI9xkVnrkliRTGxraEqWnk5GZ63xKifI=@protonmail.com>
        <5a6aa431-fdde-a329-4168-44490c37f197@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zwindl <zwindl@protonmail.com>,
        "linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "chaoming_li\@realsil.com.cn" <chaoming_li@realsil.com.cn>,
        "pkshih\@realtek.com" <pkshih@realtek.com>,
        "johannes.berg\@intel.com" <johannes.berg@intel.com>,
        "gregkh\@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45450 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdIUOt7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 10:49:59 -0400
In-Reply-To: <5a6aa431-fdde-a329-4168-44490c37f197@lwfinger.net> (Larry
        Finger's message of "Thu, 21 Sep 2017 09:21:25 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 09/21/2017 06:37 AM, Zwindl wrote:
>> Hi, I've reported to archlinux's bugzilla, and finally found out the
>> flag which caused that issue, it's the
>> `CONFIG_INTEL_IOMMU_DEFAULT_ON=y` flag, I think may this is a kernel
>> bug, more details at https://bugs.archlinux.org/task/55665
>
> My standard kernel has the following:
>
> CONFIG_INTEL_IOMMU=y
> # CONFIG_INTEL_IOMMU_SVM is not set
> # CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
>
> I will do some further testing to see if turning
> CONFIG_INTEL_IOMMU_DEFAULT_ON also breaks my system.

But not all systems have iommu so check from dmesg that iommu is really
enabled.

-- 
Kalle Valo
