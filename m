From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Mon, 10 Jul 2017 17:59:17 -0700
Message-ID: <596422E5.6010100@gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810> <595FC974.9030807@gmail.com>    <20170708.104618.2149883426031901592.davem@davemloft.net>       <20170708210617.249059b9@redhat.com> <20170710203050.54b2d8eb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, daniel@iogearbox.net,
        ast@fb.com, alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36072 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdGKA7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 20:59:36 -0400
Received: by mail-pf0-f193.google.com with SMTP id z6so16638370pfk.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 17:59:36 -0700 (PDT)
In-Reply-To: <20170710203050.54b2d8eb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2017 11:30 AM, Jesper Dangaard Brouer wrote:
> On Sat, 8 Jul 2017 21:06:17 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
>> On Sat, 08 Jul 2017 10:46:18 +0100 (WEST)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: John Fastabend <john.fastabend@gmail.com>
>>> Date: Fri, 07 Jul 2017 10:48:36 -0700
>>>   
>>>> On 07/07/2017 10:34 AM, John Fastabend wrote:    
>>>>> This series adds two new XDP helper routines bpf_redirect() and
>>>>> bpf_redirect_map(). The first variant bpf_redirect() is meant
>>>>> to be used the same way it is currently being used by the cls_bpf
>>>>> classifier. An xdp packet will be redirected immediately when this
>>>>> is called.    
>>>>
>>>> Also other than the typo in the title there ;) I'm going to CC
>>>> the driver maintainers working on XDP (makes for a long CC list but)
>>>> because we would want to try and get support in as many as possible in
>>>> the next merge window.
>>>>
>>>> For this rev I just implemented on ixgbe because I wrote the
>>>> original XDP support there. I'll volunteer to do virtio as well.    
>>>
>>> I went over this series a few times and it looks great to me.
>>> You didn't even give me some coding style issues to pick on :-)  
>>
>> We (Daniel, Andy and I) have been reviewing and improving on this
>> patchset the last couple of weeks ;-).  We had some stability issues,
>> which is why it wasn't published earlier. My plan is to test this
>> latest patchset again, Monday and Tuesday. I'll try to assess stability
>> and provide some performance numbers.
> 
> 
> Damn, I though it was stable, I have been running a lot of performance
> tests, and then this just happened :-(

Thanks, I'll take a look through the code and see if I can come up with
why this might happen. I haven't hit it on my tests yet though.

.John
