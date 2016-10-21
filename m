From: Eric Nelson <eric@nelint.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 06:48:36 -0700
Message-ID: <dba221c7-5329-4d5e-2320-c68a95caf206@nelint.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
 <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
 <CAOMZO5DG6=pNDYgT4Bf4KBj4UPOwemBHNk6PYd8DZKt6Yp0PfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Henri Roosen <henri.roosen@ginzinger.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34184 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755362AbcJUNsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 09:48:38 -0400
Received: by mail-pf0-f171.google.com with SMTP id r16so57420657pfg.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:48:38 -0700 (PDT)
In-Reply-To: <CAOMZO5DG6=pNDYgT4Bf4KBj4UPOwemBHNk6PYd8DZKt6Yp0PfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Fabio.

On 10/21/2016 06:43 AM, Fabio Estevam wrote:
> Hi Eric,
> 
> On Fri, Oct 21, 2016 at 11:39 AM, Eric Nelson <eric@nelint.com> wrote:
> 
>> Reading the i.MX28 reference manual, it appears that this SoC doesn't
>> have the RACC bit, and I missed removal of the FEC_QUIRK_HAS_RACC flag.
> 
> On MX28 the register is called HW_ENET_MAC_IPACCRXCONF.
> 
> I sent a patch that fixes the issue.
> 

I saw that. Nice catch!
