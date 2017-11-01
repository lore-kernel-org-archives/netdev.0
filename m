From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: mlx5 broken affinity
Date: Wed, 1 Nov 2017 19:02:58 -0400
Message-ID: <573060a9-19a7-9133-ef52-fa947088dabb@fb.com>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
 <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
 <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
 <CALzJLG-Z2fJibyZ74XU7XCSx-g3=YapV9VyekAYZkS5JwvkwWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sagi Grimberg <sagi@grimberg.me>,
        Networking <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54734 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932293AbdKAXDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 19:03:18 -0400
In-Reply-To: <CALzJLG-Z2fJibyZ74XU7XCSx-g3=YapV9VyekAYZkS5JwvkwWw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 06:41 PM, Saeed Mahameed wrote:
> On Wed, Nov 1, 2017 at 11:20 AM, Jes Sorensen <jsorensen@fb.com> wrote:
>> On 11/01/2017 01:21 PM, Sagi Grimberg wrote:
>> I am all in favor of making the automatic setup better, but assuming an
>> automatic setup is always right seems problematic. There could be
>> workloads where you may want to assign affinity explicitly.
>>
>> Jes
> 
> I vaguely remember Nacking Sagi's patch as we knew it would break
> mlx5e netdev affinity assumptions.
> Anyway we already submitted the mlx5e patch that removed such assumption
> 
> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.ozlabs.org_patch_809196_&d=DwIBaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=zRrmoWoylV2tnG53v9ZA2w&m=Z6xtsiQVL8xhTauY_DrOWYDhci-D49TqNKLWV_HK5Ug&s=pkxagNCZzy5-ZzMRTxIQ5pDfFq8WOSRdSx5zeQpQdBI&e= ("net/mlx5e: Distribute RSS
> table among all RX rings")
> Jes please confirm you have it.
> 
> And I agree here that user should be able to read
> /proc/irq/x/smp_affinity and even modify it if required.

Hi Saeed,

I can confirm I have that patch - the problem is also present in Linus'
current tree.

I can read smp_affinity, but I cannot write to it.

Cheers,
Jes
