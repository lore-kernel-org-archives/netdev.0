From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: enable MoCA link state change detection
Date: Wed, 1 Apr 2015 05:48:27 -0700
Message-ID: <CAGVrzca4oEs4gNmRB0frg91hheS2OT4cWrt3ni146UtCtN7LsA@mail.gmail.com>
References: <20150331220008.B9C2022023D@puck.mtv.corp.google.com>
 <20150331.210028.1632809919741182405.davem@davemloft.net> <CAGXr9JHzZU0A_+WZR616PgKGQeJBeV8AFpkEH5xgMaO8aGsi4Q@mail.gmail.com>
 <CAGXr9JH9EAN-Xr8nfJ4GCr7TEY=A8YR6jSWv9jJScFZpEw6nzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35785 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbDAMtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:49:08 -0400
Received: by obcjt1 with SMTP id jt1so77603822obc.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 05:49:07 -0700 (PDT)
In-Reply-To: <CAGXr9JH9EAN-Xr8nfJ4GCr7TEY=A8YR6jSWv9jJScFZpEw6nzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-31 19:44 GMT-07:00 Petri Gynther <pgynther@google.com>:
> On Tue, Mar 31, 2015 at 7:34 PM, Petri Gynther <pgynther@google.com> wrote:
>> On Tue, Mar 31, 2015 at 6:00 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Petri Gynther <pgynther@google.com>
>>> Date: Tue, 31 Mar 2015 15:00:08 -0700 (PDT)
>>>
>>>> @@ -513,6 +522,13 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
>>>>                       dev_err(kdev, "failed to register fixed PHY device\n");
>>>>                       return -ENODEV;
>>>>               }
>>>> +
>>>> +             if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET) {
>>>> +                     ret = fixed_phy_set_link_update(phydev,
>>>> +                                             bcmgenet_fixed_phy_link_update);
>>>
>>> This is not indented correctly.
>>>
>>> When a function call or declaration or definition spans multiple lines,
>>> arguments on the second and subsequent lines must be indented exactly
>>> to the first column after the openning parenthesis on the first line.
>>>
>>> If you are strictly using TAB characters, it is exceedingly likely
>>> that you are indenting these lines incorrectly.  You must use the
>>> appropriate number of TAB, then SPACE characters necessary to reach
>>> the correct column.
>>
>> I'm aware of the Linux indentation rules. However, if I do that in
>> this case, the second line becomes longer than 80 chars.
>
> Also, this patch still needs verification on ARM (device tree based)
> platform. Waiting to hear from Florian on that.

I am currently traveling, but I will try to give this patch a try in
the next few hours on an ARM-based platform. AFAIR, the link up/down
interrupts should work irrespective of the GENET version (1 through
4), but I will double check that too.

-- 
Florian
