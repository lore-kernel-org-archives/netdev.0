From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 22:06:12 +0000
Message-ID: <1484863558.2634.7.camel@sandisk.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
         <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
         <20170118173327.GF32481@mtr-leonro.local>
         <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
         <20170118183127.GC14198@obsidianresearch.com>
         <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
         <20170119063326.GJ32481@mtr-leonro.local>
         <20170119180308.GD8109@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "arielalmogworkemails@gmail.com" <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>
To: "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "leon@kernel.org" <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0041.outbound.protection.outlook.com ([104.47.34.41]:5792
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751807AbdASWHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 17:07:16 -0500
In-Reply-To: <20170119180308.GD8109@obsidianresearch.com>
Content-Language: en-US
Content-ID: <0506C7541F6E1E4483349F1E4A69D2B0@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 11:03 -0700, Jason Gunthorpe wrote:
> sysfs is unpopular because the 'one value per file' dogma is laregly
> unsuitable for complex mulit-value atomic changes which are common in
> netdev. You can force it to work, but it is pretty horrible..
>=20
> It is also very expensive if you want to shuttle a lot of data, eg I
> could not see doing something like 'netstat' for IB through sysfs

Since the RDMA sysfs ABI defines a user space ABI and since user space
ABIs must be backwards compatible removing the existing sysfs ABI is
not an option. We will need to evaluate on a case-by-case basis whether
new functionality should use sysfs or whether another mechanism should
be used.

Bart.=
