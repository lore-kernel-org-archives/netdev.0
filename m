From: Eric Nelson <eric@nelint.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 06:46:47 -0700
Message-ID: <9d3634bc-7778-ffc1-67bf-6fdac0078ac3@nelint.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
 <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Henri Roosen <henri.roosen@ginzinger.com>, fugang.duan@nxp.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36203 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754584AbcJUNqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 09:46:49 -0400
Received: by mail-pf0-f169.google.com with SMTP id e6so57390604pfk.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:46:49 -0700 (PDT)
In-Reply-To: <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Henri,

On 10/21/2016 06:39 AM, Eric Nelson wrote:
> Hi Henri,
> 
> On 10/21/2016 02:19 AM, Henri Roosen wrote:
>> Hi,
>>
>> Unfortunately commit-3ac72b7b63d5 "net: fec: align IP header in
>> hardware" breaks networking on an iMX28 system.
>>
>> The commit seems valid for iMX6, where it is tested okay and solves the
>> unaligned accesses.
>>
>> On iMX28 I still see unaligned accesses and networking is broken. Can
>> anyone confirm this?
>>
> 
> Reading the i.MX28 reference manual, it appears that this SoC doesn't
> have the RACC bit, and I missed removal of the FEC_QUIRK_HAS_RACC flag.
> 

Sorry. I was wrong.

The register (offset 0x1c4) is present, including the SHIFT16 bit, but
the register is named differently (HW_ENET_MAC_IPACCRXCONF).
