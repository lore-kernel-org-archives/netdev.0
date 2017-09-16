From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: RTL8192EE PCIe Wireless Network Adapter crashed with linux-4.13
Date: Sat, 16 Sep 2017 12:26:14 -0500
Message-ID: <5e2a695a-ea26-e0a3-d5eb-cf8135c1349e@lwfinger.net>
References: <2WhCEttl4IJtrTB2AkJYmhbsu-kiR_5fU0A_Z7eWW05rbVE5tB86A_ZS8ek_FQFdgaZw1bfx0wFbxOa0Ydjv1T6BzBkIHtaWTbSptcpB_kg=@protonmail.com>
 <e8e75755-f8b4-e122-ea4a-99a691405d38@lwfinger.net>
 <jB0WJNG17mSfKo9m7T26r-b2Gr7mDL4lJ-1cWxeCJ6UCsA4TsxXz4znCLhYY5EASPQciwp1rf_xtwvDR-xzwD-OTApTUFoaVmIvahleDcJk=@protonmail.com>
 <1eb67d2e-dfbc-a2d0-8949-d4336191c07b@lwfinger.net>
 <x1duse6v9TTP8Ta7rsTLlZ8DK0Ej7qq9iapef18K0eYSodmCBmfI_mX3c-3ocbPiGzEgV9weOh25dKWSbU5nIetYkfmmUxaxRpUdYFffRZA=@protonmail.com>
 <35856452-c05c-d116-f91b-0964947ec8ae@lwfinger.net>
 <2_UKRQjXR9_CXy_99R7fqRbs4VDG0hfFCMvvf4ll2BQV5C_zNiPTnHHNtoYstAGy_UF9X85pl4siU7fnXefmqbhlErxR6FqZQfIf0tADKNg=@protonmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "pkshih@realtek.com" <pkshih@realtek.com>,
        "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Zwindl <zwindl@protonmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:56200 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdIPR0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 13:26:17 -0400
In-Reply-To: <2_UKRQjXR9_CXy_99R7fqRbs4VDG0hfFCMvvf4ll2BQV5C_zNiPTnHHNtoYstAGy_UF9X85pl4siU7fnXefmqbhlErxR6FqZQfIf0tADKNg=@protonmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2017 06:27 AM, Zwindl wrote:
> Hi, I've done the test, and the weird thing happened. The kernel buit with this 
> config file https://ptpb.pw/HF1g which is from 
> https://aur.archlinux.org/packages/linux-git/  can run properly, the wifi can 
> connect, despite which version it is, but, with this config file 
> https://ptpb.pw/7GuV which comes from the archlinux's official package build 
> repo(linux-package 
> <https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/linux>), 
> all the version begin with 4.13 was failed to connect wifi.
> So, I think the issue is not caused by the kernel code, is caused by some 
> options in the config file, but I can't fully understand the meaning of these 
> options so that I can't determine which option caused that issue, what should I 
> do now, maybe report this bug to archlinux's maintainer?
> By the way, maybe I'll lost internet connection tomorrow, it's time to back to 
> university, but I'm happy to help to push the debug progress.

Yes, you need to report this to archlinux's bugzilla or maintainer, whichever is 
appropriate. I have seen a configuration error cause some feature to be silently 
missing, but leading to a WARN is rare.

I looked at your two configurations, but did not see a definitive difference.

Larry
