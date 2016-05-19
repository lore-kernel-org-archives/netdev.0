From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 19 May 2016 11:40:23 +0200
Message-ID: <CA+icZUVc+CEV4R3jnSpTQYSxqyQX-cwx77c18P5rmRVrJrXZmQ@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
	<CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
	<1463568714.13625.18.camel@intel.com>
	<CAAA5faF=SxqCt0yDTbPyUoc3gFD--_co+fRj2Jfuy=whEQvcBQ@mail.gmail.com>
	<1463575273.13625.23.camel@intel.com>
	<CAAA5faHtbt8oyKEQOJ+NMBKR24b7Nvm6uJ2qZid1sWY58e7f+A@mail.gmail.com>
	<1463581411.29999.1.camel@intel.com>
	<CA+55aFxThzV3myrHv0XZbubEdGhg5=rGE6dK=+L1ddc9sufdCQ@mail.gmail.com>
	<CA+55aFxTXem=w71Q4pJCgeypqLzt+zk6KqoPM547usNDYxAjpg@mail.gmail.com>
	<CAAA5faEoCDkgHmoGtFamS2G5KaUZ5j=pVc6tsPj2dG80ZFNedQ@mail.gmail.com>
	<CAAA5faFWPCrk0C3sjT==VMVCq1jcR8_HANV=RRE-Ummv4_psHA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Coelho, Luciano" <luciano.coelho@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: Reinoud Koornstra <reinoudkoornstra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33572 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753433AbcESJkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 05:40:25 -0400
In-Reply-To: <CAAA5faFWPCrk0C3sjT==VMVCq1jcR8_HANV=RRE-Ummv4_psHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/16, Reinoud Koornstra <reinoudkoornstra@gmail.com> wrote:
> On Thu, May 19, 2016 at 2:20 AM, Reinoud Koornstra
> <reinoudkoornstra@gmail.com> wrote:
>> On Wed, May 18, 2016 at 12:51 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>> On Wed, May 18, 2016 at 11:45 AM, Linus Torvalds
>>> <torvalds@linux-foundation.org> wrote:
>>>>
>>>> From what I can tell, there's a merge bug in commit 909b27f70643,
>>>> where David seems to have lost some of the changes to
>>>> iwl_mvm_set_tx_cmd().
>>>>
>>>> I do not know if that's the reason for the problem I see. But I will
>>>> test.
>>>
>>> Yes. The attached patch that fixes the incorrect merge seems to fix
>>> things for me.
>>>
>>> That should mean that the assumption that this problem existed in v4.6
>>> too was wrong, because the incorrect merge came in later. I think
>>> Luciano mis-understood "v4.6+" to mean plain v4.6.
>>>
>>> Reinoud Koornstra, does this patch fix things for you too?
>>
>> Indeed, I meant 4.6+, not 4.6.
>> The patch you attached doesn't change existing code for me in 4.6+ as
>> these two lines are already in there.
>> Thanks,
>>
>> Reinoud.
>>
>
> In the 4.6+ code from today I reverted commit 5c08b0f5026f.
> Now iwlwifi works fine for me again.
> So it's as the Intel guys suspected.
> I'll attached my revert compared to the current 4.6+ development code.
> Thanks,
>

I am not affected by any of these iwlwifi issues.

Can you next time add the commit-subject together with the commit-id,
like this...

commit 5c08b0f5026fcc13efb947c4d1f2ca3558145f68
"iwlwifi: mvm: don't override the rate with the AMSDU len"

...it's easier for followers of this thread.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5c08b0f5026fcc13efb947c4d1f2ca3558145f68
