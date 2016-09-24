From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/6] isdn/hisax: clean function declaration in hscx.c up
Date: Sat, 24 Sep 2016 17:17:17 +0300
Message-ID: <70bf808d-bc5f-ce91-307e-99ec735c70df@cogentembedded.com>
References: <1474694662-7527-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474694662-7527-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/24/2016 8:24 AM, Baoyou Xie wrote:

> We get 1 warning when building kernel with W=1:
> drivers/isdn/hisax/hscx.c:175:1: warning: no previous prototype for 'open_hscxstate' [-Wmissing-prototypes]
>
> In fact, this function is declared in
> drivers/isdn/hisax/elsa_ser.c, but should be
> declard in a header file, thus can be recognized in other file.

    Declared.

> So this patch moves the declaration into drivers/isdn/hisax/hscx.h.
>
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
[...]

MBR, Sergei
