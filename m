From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [scr265482] ip_tunnel.c
Date: Thu, 24 Nov 2016 20:12:18 -0800
Message-ID: <CAM_iQpVCwrdzWztMVyjdqNqoHPK9xuGCiEUWy5iUH3u7VWOaqw@mail.gmail.com>
References: <F41877A268BCDE49BAEE2286FA8C269F6FECFC5E@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "security@kernel.org" <security@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cve-request@mitre.org" <cve-request@mitre.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34687 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbcKYENY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 23:13:24 -0500
Received: by mail-yw0-f177.google.com with SMTP id t125so53456936ywc.1
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 20:12:39 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFC5E@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 5:39 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) <=
yuliyang1@le.com> wrote:
> BTW:
>
>    Which RFC suggests UINT_MAX as GRE sequence number?  Can you show me?


https://tools.ietf.org/html/rfc2890

"The receiver maintains the sequence number value of the last successfully
decapsulated packet. Upon establishment of the GRE tunnel, this value
should be set to (2**32)-1."


I agree with Eric here, this is a minor issue, not a serious bug at all.
Please test my patch since you can reproduce it.

BTW, please don't top-post here.

Thanks.
