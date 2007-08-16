From: "Paul Gortmaker" <paul.gortmaker@gmail.com>
Subject: Re: [2.6 patch] remove Documentation/networking/net-modules.txt
Date: Wed, 15 Aug 2007 23:22:36 -0400
Message-ID: <7d1d9c250708152022s3c21be16x488a4f9705cd3b3d@mail.gmail.com>
References: <20070814212604.GW18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:61811 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbXHPDWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 23:22:37 -0400
Received: by wr-out-0506.google.com with SMTP id 36so95884wra
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 20:22:36 -0700 (PDT)
In-Reply-To: <20070814212604.GW18945@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/14/07, Adrian Bunk <bunk@kernel.org> wrote:
> According to git, the only one who touched this file during the last
> 5 years was me when removing drivers...
>
> modinfo offers less ancient information.
>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>

Fine by me for any of the old stuff I was responsible for...

Acked-by: Paul Gortmaker <paul.gortmaker@gmail.com>



> -
> -       8390 based Network Modules              (Paul Gortmaker, Nov 12, 1995)
> -       --------------------------
> -
> -(Includes: smc-ultra, ne, wd, 3c503, hp, hp-plus, e2100 and ac3200)
> -
> -The 8390 series of network drivers now support multiple card systems without
> -reloading the same module multiple times (memory efficient!) This is done by
> -specifying multiple comma separated values, such as:
> -
> -       insmod 3c503.o io=0x280,0x300,0x330,0x350  xcvr=0,1,0,1
> -
