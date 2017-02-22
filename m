From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] netfilter: nf_ct_expect:
 nf_ct_expect_related_report(): Return zero on success,
Date: Wed, 22 Feb 2017 13:00:50 +0300
Message-ID: <d5e71d84-1d3e-b2c9-30fe-2dcabdfbea88@cogentembedded.com>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fgao@ikuai8.com, pablo@netfilter.org
To: Jarno Rajahalme <jarno@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34454 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753770AbdBVKAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 05:00:53 -0500
Received: by mail-lf0-f47.google.com with SMTP id g134so3347619lfe.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 02:00:52 -0800 (PST)
In-Reply-To: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 2/22/2017 2:25 AM, Jarno Rajahalme wrote:

> Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()

    Need at least 12 hex digits.

> returns void") inadvertently changed the successful return value of
> nf_ct_expect_related_report() from 0 to 1, which caused openvswitch
> conntrack integration fail in FTP test cases.
>
> Fix this by always returning zero on the success code path.
>
> Fixes: 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert() returns void")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
[...]

MBR, Sergei
