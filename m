From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH v2 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test
Date: Thu, 26 Jun 2014 19:43:12 +0400
Message-ID: <CAOJe8K0qhOv-zP3BLihvxvt7_b+PHtStommdXzN=-7iLe7sLvw@mail.gmail.com>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
	<1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
	<1403771455.18572.8.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:65528 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbaFZPnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 11:43:13 -0400
Received: by mail-oa0-f46.google.com with SMTP id m1so4130616oag.33
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 08:43:12 -0700 (PDT)
In-Reply-To: <1403771455.18572.8.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/26/14, Michael Ellerman <mpe@ellerman.id.au> wrote:
> On Wed, 2014-06-25 at 21:34 +0400, Denis Kirjanov wrote:
>> We have to return the boolean here if the tag presents
>> or not, not just ANDing the TCI with the mask which results to:
>>
>> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
>> [  709.412245] ret 4096 != 1
>> [  709.412332] ret 4096 != 1
>> [  709.412333] FAIL (2 times)
>
> Hi Denis,
>
> Is this the same version of test_bpf that is in Linus' tree?

You didn't enable the JIT.
> I don't see any fails with that version, am I missing something?
>
>   [  187.690640] test_bpf: #18 LD_VLAN_TAG_PRESENT 46 50 PASS
>
> cheers
>
>
>
