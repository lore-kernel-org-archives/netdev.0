From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP reaching to maximum throughput after a long time
Date: Tue, 12 Apr 2016 13:11:23 -0700
Message-ID: <570D566B.8050302@candelatech.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
 <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
 <570D0E94.3080006@candelatech.com>
 <AE1C82FB3D0EC64DB1F752C81CBD110139101889@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: "Machani, Yaniv" <yanivma@ti.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD110139101889@DFRE01.ent.ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/12/2016 12:31 PM, Machani, Yaniv wrote:
> On Tue, Apr 12, 2016 at 18:04:52, Ben Greear wrote:
>> On 04/12/2016 07:52 AM, Eric Dumazet wrote:
>>> On Tue, 2016-04-12 at 12:17 +0000, Machani, Yaniv wrote:
>>>>
>>
>> If you are using 'Cubic' TCP congestion control, then please try
>> something different.
>> It was broken last I checked, at least when used with the ath10k driver.
>>
>
> Thanks Ben, this indeed seems to be the issue !
> Switching to reno got me to max throughput instantly.
>
> I'm still looking through the thread you have shared, but from what I understand there is no planned fix for it ?

I think at the time it was blamed on ath10k and no one cared to try to fix it.

Or, maybe no one really uses CUBIC anymore?

Either way, I have no plans to try to fix CUBIC, but maybe someone who knows
this code better could give it a try.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
