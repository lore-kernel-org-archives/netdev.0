From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 4/9] nfp: extend flower add flow offload
Date: Wed, 28 Jun 2017 23:48:29 -0700
Message-ID: <20170628234829.76098a18@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-5-git-send-email-simon.horman@netronome.com>
        <ceb96fbd-c768-5bb2-cb44-f1bc7ecb4849@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <oss-drivers@netronome.com>,
        "Pieter Jansen van Vuuren" <pieter.jansenvanvuuren@netronome.com>
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36633 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751614AbdF2Gsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 02:48:32 -0400
Received: by mail-pg0-f54.google.com with SMTP id u62so43219853pgb.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 23:48:32 -0700 (PDT)
In-Reply-To: <ceb96fbd-c768-5bb2-cb44-f1bc7ecb4849@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jun 2017 14:18:07 +0800, Yunsheng Lin wrote:
> > +	if (mask_basic->n_proto) { =20
> cpu_to_be16=EF=BC=88mask_basic->n_proto=EF=BC=89
> remove cpu_to_be16 in case.

Thanks, but this is incorrect.  Byte swapping constants is done at
compilation time - therefore it's preferred.
