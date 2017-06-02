From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 2 Jun 2017 16:31:18 -0400
Message-ID: <4c164e09-0103-7daf-e9f8-9260223ada08@fb.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
 <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
 <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew@mail.gmail.com>
 <f47d7519-4f58-bc94-2387-20342afd91b8@fb.com>
 <AM4PR0501MB19406FF2555888457C00E217DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54752 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751326AbdFBUbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 16:31:35 -0400
In-Reply-To: <AM4PR0501MB19406FF2555888457C00E217DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2017 03:24 AM, Ilan Tayari wrote:
>> -----Original Message-----
>> From: Jes Sorensen [mailto:jsorensen@fb.com]
>>
>> On 05/26/2017 04:29 AM, Saeed Mahameed wrote:
>>> On Thu, May 25, 2017 at 11:48 PM, Jes Sorensen <jsorensen@fb.com> wrote:
>>>> On 05/25/2017 06:40 AM, Saeed Mahameed wrote:
>>> Hi Jes,
>>>
>>> No, It is clearly stated in the commit message :
>>>
>>> "The FPGA is a bump-on-the-wire and thus affects operation of
>>> the mlx5_core driver on the ConnectX ASIC."
>>>
>>> Which means mlx5 FPGA user can only write logic which affects only
>>> packets going in/out
>>> A ConnectX chip - so it is only network stuff -.
>>>
>>>> We have this with other devices in the kernel where a primary device
>> driver
>>>> provides an interface for an additional sub-driver to access another
>> device
>>>> behind it. Like bt-coexist in some of the wifi drivers allowing access
>> to a
>>>> bluetooth device behind it.
>>>
>>> Blutooth over wifi or vise versa is a very good example to what you
>>> are requesting.
>>> But, it doesn't fit to what we are trying to do here. mlx5 FGPA is a
>>> ConnectX card feature, not a new protocol.
>>
>> In that case it would need to be an optional module that can be enabled
>> or disabled at build time.
> 
> Jes,
> 
> It is already modular like that. See CONFIG_MLX5_FPGA.

[jes@xpeas netdev.git]$ grep CONFIG_MLX5_FPGA 
drivers/net/ethernet/mellanox/mlx5/core/*
[jes@xpeas netdev.git]$

Which git tree am I supposed to look at?

Jes
