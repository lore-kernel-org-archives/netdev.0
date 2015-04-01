From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: enable MoCA link state change detection
Date: Tue, 31 Mar 2015 19:34:57 -0700
Message-ID: <CAGXr9JHzZU0A_+WZR616PgKGQeJBeV8AFpkEH5xgMaO8aGsi4Q@mail.gmail.com>
References: <20150331220008.B9C2022023D@puck.mtv.corp.google.com>
	<20150331.210028.1632809919741182405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33259 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbbDACe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 22:34:58 -0400
Received: by qgfa8 with SMTP id a8so32046548qgf.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 19:34:57 -0700 (PDT)
In-Reply-To: <20150331.210028.1632809919741182405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 6:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Petri Gynther <pgynther@google.com>
> Date: Tue, 31 Mar 2015 15:00:08 -0700 (PDT)
>
>> @@ -513,6 +522,13 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
>>                       dev_err(kdev, "failed to register fixed PHY device\n");
>>                       return -ENODEV;
>>               }
>> +
>> +             if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET) {
>> +                     ret = fixed_phy_set_link_update(phydev,
>> +                                             bcmgenet_fixed_phy_link_update);
>
> This is not indented correctly.
>
> When a function call or declaration or definition spans multiple lines,
> arguments on the second and subsequent lines must be indented exactly
> to the first column after the openning parenthesis on the first line.
>
> If you are strictly using TAB characters, it is exceedingly likely
> that you are indenting these lines incorrectly.  You must use the
> appropriate number of TAB, then SPACE characters necessary to reach
> the correct column.

I'm aware of the Linux indentation rules. However, if I do that in
this case, the second line becomes longer than 80 chars.
