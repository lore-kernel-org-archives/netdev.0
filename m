From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [GIT] Networking
Date: Tue, 19 Jan 2016 15:08:20 +0200
Message-ID: <87r3hd4szf.fsf@kamboji.qca.qualcomm.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
	<56978094.4050302@arm.com> <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
	<569CCCD2.4040105@arm.com> <569D61BA.8020701@broadcom.com>
	<569DFA0A.6070900@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <569DFA0A.6070900-5wv7dgnIgG8@public.gmane.org> (Marc Zyngier's message of "Tue, 19
	Jan 2016 08:55:38 +0000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org> writes:

>>>> Should we revert the patch or can you Hante fix this? The revert doesn't
>>>> seem to be trivial so I would appreciate if someone could send a patch.
>>>
>>> I've worked out a partial revert (see below) that allows my system to
>>> boot, but I'd rather see a proper fix from the maintainer of this code.
>> 
>> Hi Marc,
>> 
>> Thanks for the patch, but Hante has created a different patch basically
>> deferring the allocation of the sgtable. Feel free to give it a spin on
>> your box and share the results.
>
> Hi Arend,
>
> This patch fixes indeed the problem, thanks (I had to undo the mangling
> your mailer had done, though). So feel free to add my:
>
> Reported-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
> Tested-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
>
> It would be good if this could make it in -rc1.

I doubt it makes it to -rc1, most likely to -rc2. But let's see.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
