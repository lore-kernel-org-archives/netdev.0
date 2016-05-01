From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 10/12] net/mlx5e: Create aRFS flow tables
Date: Sun, 1 May 2016 11:12:37 +0300
Message-ID: <CALzJLG_0Hv4dh-Bxq7g_3fP_sgiQ8f=Qam0T+kC4v94gs_xyJw@mail.gmail.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
 <1461883002-8912-11-git-send-email-saeedm@mellanox.com> <20160501021845.GA10348@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:36324 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbcEAIM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 04:12:58 -0400
Received: by mail-yw0-f170.google.com with SMTP id o66so238194952ywc.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 01:12:57 -0700 (PDT)
In-Reply-To: <20160501021845.GA10348@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 1, 2016 at 5:18 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Apr 29, 2016 at 01:36:40AM +0300, Saeed Mahameed wrote:
>> From: Maor Gottlieb <maorg@mellanox.com>
>>  mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
>> +mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o
>
> this line breaks the build when RFS is on
> and CONFIG_MLX5_CORE_EN is off.
>

Will Fix.

Thank you Alexei.
