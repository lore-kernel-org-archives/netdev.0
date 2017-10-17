From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Tue, 17 Oct 2017 02:44:59 +0200
Message-ID: <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl>
References: <1507121766.30720.4.camel@cohaesio.com>
 <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com>
 <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
 <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
 <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Pavlos Parissis <pavlos.parissis@gmail.com>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:58081 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755063AbdJQApC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 20:45:02 -0400
In-Reply-To: <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-10-17 o 01:56, Alexander Duyck pisze:
> On Mon, Oct 16, 2017 at 4:34 PM, Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>>
>> W dniu 2017-10-16 o 18:26, Paweł Staszewski pisze:
>>
>>>
>>> W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
>>>> On 15/10/2017 02:58 πμ, Alexander Duyck wrote:
>>>>> Hi Pawel,
>>>>>
>>>>> To clarify is that Dave Miller's tree or Linus's that you are talking
>>>>> about? If it is Dave's tree how long ago was it you pulled it since I
>>>>> think the fix was just pushed by Jeff Kirsher a few days ago.
>>>>>
>>>>> The issue should be fixed in the following commit:
>>>>>
>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=2b9478ffc550f17c6cd8c69057234e91150f5972
>>>>>
>>>> Do you know when it is going to be available on net-next and linux-stable
>>>> repos?
>>>>
>>>> Cheers,
>>>> Pavlos
>>>>
>>>>
>>> I will make some tests today night with "net" git tree where this patch is
>>> included.
>>> Starting from 0:00 CET
>>> :)
>>>
>>>
>> Upgraded and looks like problem is not solved with that patch
>> Currently running system with
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/
>> kernel
>>
>> Still about 0.5GB of memory is leaking somewhere
>>
>> Also can confirm that the latest kernel where memory is not leaking (with
>> use i40e driver intel 710 cards) is 4.11.12
>> With kernel 4.11.12 - after hour no change in memory usage.
>>
>> also checked that with ixgbe instead of i40e with same  net.git kernel there
>> is no memleak - after hour same memory usage - so for 100% this is i40e
>> driver problem.
> So how long was the run to get the .5GB of memory leaking?
1 hour

>
> Also is there any chance of you being able to bisect to determine
> where the memory leak was introduced since as you pointed out it
> didn't exist in 4.11.12 so odds are it was introduced somewhere
> between 4.11 and the latest kernel release.
Can be hard cause currently need to back to 4.11.12 - this is production 
host/router
Will try to find some free/test router for tests/bicects with i40e 
driver (intel 710 cards)

>
> Thanks.
>
> - Alex
>
