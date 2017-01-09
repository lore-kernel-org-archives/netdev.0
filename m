From: maowenan <maowenan@huawei.com>
Subject: Re: [PATCH net-next] net:add one common config ARCH_WANT_RELAX_ORDER
 to support relax ordering.
Date: Mon, 9 Jan 2017 13:33:19 +0800
Message-ID: <eeb5dc13-87e0-f66c-d3d6-35cc6d55ee78@huawei.com>
References: <1483696364-8680-1-git-send-email-maowenan@huawei.com>
 <CAKgT0Uencn48k69UYt24B75O--5GL9pC-haYh4do4rxeN4pYgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:6038 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbdAIFda (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 00:33:30 -0500
In-Reply-To: <CAKgT0Uencn48k69UYt24B75O--5GL9pC-haYh4do4rxeN4pYgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/1/6 23:41, Alexander Duyck wrote:
> On Fri, Jan 6, 2017 at 1:52 AM, Mao Wenan <maowenan@huawei.com> wrote:
>> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
>> enhance the performance for some cpu architecure, such as SPARC and so on.
>> Currently it only supports one special cpu architecture(SPARC) in 82599
>> driver to enable RO feature, this is not very common for other cpu architecture
>> which really needs RO feature.
>> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
>> and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
>>
>> Signed-off-by: Mao Wenan <maowenan@huawei.com>
>> ---
>>  arch/sparc/Kconfig                              | 1 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
>>  2 files changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
>> index cf4034c..68ac5c7 100644
>> --- a/arch/sparc/Kconfig
>> +++ b/arch/sparc/Kconfig
>> @@ -44,6 +44,7 @@ config SPARC
>>         select CPU_NO_EFFICIENT_FFS
>>         select HAVE_ARCH_HARDENED_USERCOPY
>>         select PROVE_LOCKING_SMALL if PROVE_LOCKING
>> +       select ARCH_WANT_RELAX_ORDER
>>
>>  config SPARC32
>>         def_bool !64BIT
> 
> 
> I'm pretty sure this is incomplete.  I think you need to add a couple
> lines to arch/Kconfig so that the config option itself is listed
> somewhere.  You might look at using something like HAVE_CMPXCHG_DOUBLE
> as an example.
> 
> - Alex
> 
> 

thank you for comments, i will send v2 patch soon.
