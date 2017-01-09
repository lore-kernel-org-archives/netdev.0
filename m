From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 0/4] net: ethernet: ti: cpsw: correct common res usage
Date: Mon, 9 Jan 2017 11:11:04 -0600
Message-ID: <b1190d93-ae4a-b10b-d780-0a5f0328e13b@ti.com>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ivan,

On 01/08/2017 10:40 AM, Ivan Khoronzhuk wrote:
> This series is intended to remove unneeded redundancies connected with
> common resource usage function.
>
> Based on net-next/master
> Tested on am572x idk
>
> Ivan Khoronzhuk (4):
>   net: ethernet: ti: cpsw: remove dual check from common res usage
>     function
>   net: ethernet: ti: cpsw: don't disable interrupts in ndo_open
>   net: ethernet: ti: cpsw: don't duplicate ndev_running
>   net: ethernet: ti: cpsw: don't duplicate common res in rx handler
>

thanks for the patches - I'll need some time to review them.

>  drivers/net/ethernet/ti/cpsw.c | 57 ++++++++++++++----------------------------
>  1 file changed, 19 insertions(+), 38 deletions(-)
>

-- 
regards,
-grygorii
