From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?B?UmU6IOetlOWkjTogW3NjcjI2NTQ4Ml0gaXBfdHVubmVsLmM=?=
Date: Thu, 24 Nov 2016 21:41:09 -0800
Message-ID: <CAM_iQpX9yG4vPFKmTUKVz6MyspQRjd34ncZ4Psby8eHdfTBj+w@mail.gmail.com>
References: <F41877A268BCDE49BAEE2286FA8C269F6FECFC5E@LETV-MBX-IDC09.letv.local>
 <CAM_iQpVCwrdzWztMVyjdqNqoHPK9xuGCiEUWy5iUH3u7VWOaqw@mail.gmail.com> <F41877A268BCDE49BAEE2286FA8C269F6FECFDBC@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34036 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbcKYFmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 00:42:03 -0500
Received: by mail-io0-f181.google.com with SMTP id c21so104731172ioj.1
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 21:41:30 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFDBC@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 9:11 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) <=
yuliyang1@le.com> wrote:
>> Please test my patch since you can reproduce it.
>
>         Thanks cong, but Eric had said: "Really, this is not something th=
at can be solved by using 'a different initial sequence number'"
>         So I don't think it's nessary to test you patch, anyway thank you=
 very much.

That is correct, I missed the signed cast, it is similar to the jiffies tes=
t,
for the overflow case, which means no matter which value we pick,
we could drop packet as it is.
