From: Reinoud Koornstra <reinoudkoornstra@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 19 May 2016 02:20:03 -0600
Message-ID: <CAAA5faEoCDkgHmoGtFamS2G5KaUZ5j=pVc6tsPj2dG80ZFNedQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Coelho, Luciano" <luciano.coelho@intel.com>,
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxTXem=w71Q4pJCgeypqLzt+zk6KqoPM547usNDYxAjpg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 12:51 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, May 18, 2016 at 11:45 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> From what I can tell, there's a merge bug in commit 909b27f70643,
>> where David seems to have lost some of the changes to
>> iwl_mvm_set_tx_cmd().
>>
>> I do not know if that's the reason for the problem I see. But I will test.
>
> Yes. The attached patch that fixes the incorrect merge seems to fix
> things for me.
>
> That should mean that the assumption that this problem existed in v4.6
> too was wrong, because the incorrect merge came in later. I think
> Luciano mis-understood "v4.6+" to mean plain v4.6.
>
> Reinoud Koornstra, does this patch fix things for you too?

Indeed, I meant 4.6+, not 4.6.
The patch you attached doesn't change existing code for me in 4.6+ as
these two lines are already in there.
Thanks,

Reinoud.

>
>                        Linus
