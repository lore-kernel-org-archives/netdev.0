From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv4] wlcore: add wl1285 compatible
Date: Mon, 22 May 2017 10:30:10 -0400 (EDT)
Message-ID: <20170522.103010.1779800840743690143.davem@davemloft.net>
References: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
        <8737bx5jgr.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org, sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8737bx5jgr.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Mon, 22 May 2017 12:28:20 +0300

> Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> writes:
> 
>> Motorola Droid 4 uses a WL1285C. With differences between the
>> chips not being public let's add explicit binding for wl1285
>> instead of relying on wl1283 being very similar.
>>
>> Reviewed-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Acked-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>> Acked-by: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
>> Signed-off-by: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
>> ---
>> Hi Dave,
>>
>> I previously send this in two patches, but its hard to apply without
>> requiring multiple kernel releases (the driver must be updated before
>> the DTS change). Since the actual change is not very complex Marcel
>> Holtmann & Tony Lindgren suggested, that I send this directly to you
>> in a single patch for inclusion into 4.12. This also means, that the
>> remaining series can be queued normally for 4.13.
> 
> I noticed that Dave set this patch to Awaiting Upstream state on his
> patchwork:
> 
> https://patchwork.ozlabs.org/patch/759042/
> 
> Which makes me suspect that he is waiting me to apply this (as I
> normally apply wlcore patches). Dave, should I actually take this patch?
> What do you prefer?

Anything that touches wireless drivers I defer to you, yes.
