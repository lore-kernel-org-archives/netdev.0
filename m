From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlwifi: mvm: add reorder buffer per queue
Date: Mon, 16 May 2016 11:15:43 -0700
Message-ID: <CAA93jw7hkK8+Zx+DJEWDUGxKhSkr6wTLpNmbXYiVc+8OZL-OVA@mail.gmail.com>
References: <20160513085428.GA13194@mwanda>
	<1463398895.25219.82.camel@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Sara Sharon <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463398895.25219.82.camel-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I can't even describe how much I hate the concept of the reorder
buffer in general. Ordering is the endpoints problem.

Someday, after we get fq_codeled, short queues again, I'll be able to s=
how why.

On Mon, May 16, 2016 at 4:41 AM, Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org> wrote:
> On Fri, 2016-05-13 at 11:54 +0300, Dan Carpenter wrote:
>> Hello Sara Sharon,
>>
>> The patch b915c10174fb: "iwlwifi: mvm: add reorder buffer per queue"
>> from Mar 23, 2016, leads to the following static checker warnings:
>>
>>       drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912
>> iwl_mvm_rx_mpdu_mq()
>>       error: potential NULL dereference 'sta'.
>>
>>       drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912
>> iwl_mvm_rx_mpdu_mq()
>>       error: we previously assumed 'sta' could be null (see line 796=
)
>
> Thanks for the analysis and report, Dan!
>
> I have queued a fix for this through our internal tree.
>
> --
> Cheers,
> Luca.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht
Let's go make home routers and wifi faster! With better software!
http://blog.cerowrt.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
