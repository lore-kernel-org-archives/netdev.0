From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 15:47:41 +0200
Message-ID: <87my01m0zm.fsf@purkki.valot.fi>
References: <877hr5nkx0.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
	<87wrz5m3cd.fsf@purkki.valot.fi>
	<20100126.050645.184040277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100126.050645.184040277.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's message of "Tue\, 26 Jan 2010 05\:06\:45 -0800 \(PST\)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
> Date: Tue, 26 Jan 2010 14:56:50 +0200
>
>> In my opinion we already now need a universal solution for the user
>> space applications to classify their streams. Having a local solution
>> doesn't get us far, people don't want to configure their laptops or
>> phones, they just want to use them :)
>
> And similarly your organization's administartion doesn't want to
> prioritize bittorrent traffic a specific fixed way just because your
> application sets some bits in the TOS field of it's packets.
>
> Prioritization policies have no meaning outside of your local realm,
> and that's just a fact of life.

Yes, that's what I have understood.

> So what typically happens is that applications do nothing.

But that's just because of mistakes with DiffServ and other QoS
"frameworks". They didn't bother to specify how applications should
use these. And what matters here IMHO.

> And machines on the ingress to a network realm change the TOS based
> field upon classification decisions made by parsing the packet by the
> router/firewall/whatever.
>
> The packet gets QoS treatment within the realm, but completely
> determined by local policy within that realm.
>
> And then on egress from the realm the TOS field has absolutely
> no meaning at all to the next network segment.

And you are perfectly right, as always. My choise of using the word
"universal" was bad. With word "universal" I meant to use same network
QoS API with different network technologies: ethernet, wi-fi,
bluetooth etc.

But we don't need to solve everything in one go, instead we can make
small steps. The first step is to start pushing applications to
classify their streams. That's the enabler to get some sort of QoS
support, at least to inside kernel and to the next hop. With luck, in
future it might get more widely used.

I was hoping to base the classification on some standard, but there
doesn't really seem to be one which would specify a complete solution.
But that's ok, we can always create a de facto standard :)

I'm curious how other operation systems handle this? Or is it a
similar situation, nobody just doesn't use QoS for anything?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
