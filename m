From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next 16/20] net: sched: cls_bpf: no need to call tcf_exts_change
 for newly allocated struct
Date: Mon, 31 Jul 2017 12:02:48 +0200
Message-ID: <597F0048.4070202@iogearbox.net>
References: <20170728144042.6380-1-jiri@resnulli.us> <20170728144042.6380-17-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46203 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdGaKCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 06:02:51 -0400
In-Reply-To: <20170728144042.6380-17-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 04:40 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> As the prog struct was allocated right before cls_bpf_set_parms call,
> no need to use tcf_exts_change to do atomic change, and we can just
> fill-up the unused exts struct directly by tcf_exts_validate.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
