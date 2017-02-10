From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Fri, 10 Feb 2017 08:43:43 -0800
Message-ID: <5fcaaf0e-5f35-fac8-c448-a29aeef9bf0f@candelatech.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
 <CAJ-VmonrHpS3MArM9ohHgLvb6xspP_gnVVeJWA9F-pjUpJ+LZA@mail.gmail.com>
 <87y3xi4b28.fsf@qca.qualcomm.com> <5899DDD7.7000605@candelatech.com>
 <87tw82il32.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Adrian Chadd <adrian@freebsd.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 =?UTF-8?Q?Amadeusz_S=c5=82awi=c5=84ski?= <amadeusz.slawinski@tieto.com>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <87tw82il32.fsf@kamboji.qca.qualcomm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 02/09/2017 11:03 PM, Valo, Kalle wrote:
> Ben Greear <greearb@candelatech.com> writes:
>
>> On 02/07/2017 01:14 AM, Valo, Kalle wrote:
>>> Adrian Chadd <adrian@freebsd.org> writes:
>>>
>>>> Removing this method makes the diff to FreeBSD larger, as "vif" in
>>>> FreeBSD is a different pointer.
>>>>
>>>> (Yes, I have ath10k on freebsd working and I'd like to find a way to
>>>> reduce the diff moving forward.)
>>>
>>> I don't like this "(void *) vif->drv_priv" style that much either but
>>> apparently it's commonly used in Linux wireless code and already parts
>>> of ath10k. So this patch just unifies the coding style.
>>
>> Surely the code compiles to the same thing, so why add a patch that
>> makes it more difficult for Adrian and makes the code no easier to read
>> for the rest of us?
>
> Because that's the coding style used already in Linux. It's great to see
> that parts of ath10k can be used also in other systems but in principle
> I'm not very fond of the idea starting to reject valid upstream patches
> because of driver forks.

There are lots of people trying to maintain out-of-tree or backported patches to ath10k,
and every time there is a meaningless style change, that just makes us
waste more time on useless work instead of having time to work on more important
matters.

Thanks,
Ben

> I think backports project is doing it right, it's not limiting upstream
> development in any way and handles all the API changes internally. Maybe
> FreeBSD could do something similar?
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
