From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [ovs-dev] [PATCH 2/2] openvswitch: Optimize operations for OvS
 flow_stats.
Date: Tue, 18 Jul 2017 13:39:36 +0800
Message-ID: <5A8CA8BA-DB4C-4CFB-B772-C0BCAEBBFDDA@gmail.com>
References: <1500272964-27238-1-git-send-email-xiangxia.m.yue@gmail.com>
 <1500272964-27238-2-git-send-email-xiangxia.m.yue@gmail.com>
 <CAOrHB_AVZP3DVER5wrU_hBL-8uHcMBKPL+xNDv_mOZxKRVPopw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: ovs dev <dev@openvswitch.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34737 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdGRFjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 01:39:36 -0400
Received: by mail-pf0-f196.google.com with SMTP id o88so1433071pfk.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 22:39:35 -0700 (PDT)
In-Reply-To: <CAOrHB_AVZP3DVER5wrU_hBL-8uHcMBKPL+xNDv_mOZxKRVPopw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 18, 2017, at 11:14 AM, Pravin Shelar <pshelar@ovn.org> wrote:
>=20
>>=20
>> This patch adds cpumask struct, the cpu_used_mask stores the cpu_id
>> that the flow used. And we only check the flow_stats on the cpu we
>> used, and it is unncessary to check all possible cpu when getting,
>> cleaning, and updating the flow_stats. Adding the cpu_used_mask to
>> sw_flow struct does=E2=80=99t increase the cacheline number.
>>=20
>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
>=20
> Patch looks good to me. I have one comment.

Thanks. I will sent v2 and add =E2=80=9CAcked-by=E2=80=9D.=
