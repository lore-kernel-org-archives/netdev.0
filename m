From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: bnx2x: fix improper return value
Date: Sun, 4 Dec 2016 13:24:25 +0300
Message-ID: <3bd7d66c-bfcb-f462-cacd-f211170c12f5@cogentembedded.com>
References: <1480840746-7498-1-git-send-email-bianpan201604@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201604@163.com>,
        Michal Kalderon <michal.kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480840746-7498-1-git-send-email-bianpan201604@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/4/2016 11:39 AM, Pan Bian wrote:

> From: Pan Bian <bianpan2016@163.com>
>
> Marco BNX2X_ALLOC_AND_SET(arr, lbl, func) calls kmalloc() to allocate

    Macro.

> memory, and jumps to label "lbl" if the allocation fails. Label "lbl"
> first cleans memory and then returns variable rc. Before calling the
> macro, the value of variable rc is 0. Because 0 means no error, the
> callers of bnx2x_init_firmware() may be misled. This patch fixes the bug,
> assigning "-ENOMEM" to rc before calling macro NX2X_ALLOC_AND_SET().
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189141
>
> Signed-off-by: Pan Bian <bianpan2016@163.com>
[...]

MBR, Sergei
