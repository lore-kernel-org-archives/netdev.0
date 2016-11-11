From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Fri, 11 Nov 2016 15:24:45 -0800
Message-ID: <CAOrHB_DsY2bFYbeG1GnmNXN8Bs8AtFHgi2JjJ70yb1d6vY4oFA@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-3-git-send-email-pshelar@ovn.org> <20161109171018.69d08ff9@griffin>
 <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
 <20161110104703.7386ab29@griffin> <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
 <20161110193347.0e81d68b@griffin> <CAOrHB_AGV4x4G4QYFAaWNYgckvkDAS-prp65CgXfTqB4KoxHTw@mail.gmail.com>
 <20161111121436.56b214ab@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:33523 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756524AbcKKXYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 18:24:50 -0500
Received: from mfilter29-d.gandi.net (mfilter29-d.gandi.net [217.70.178.160])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 3870517209C
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2016 00:24:48 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter29-d.gandi.net (mfilter29-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id NQdJXWtoGlil for <netdev@vger.kernel.org>;
        Sat, 12 Nov 2016 00:24:46 +0100 (CET)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id A9DCB172098
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2016 00:24:46 +0100 (CET)
Received: by mail-qk0-f181.google.com with SMTP id n204so37506577qke.2
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 15:24:46 -0800 (PST)
In-Reply-To: <20161111121436.56b214ab@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 3:14 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 10 Nov 2016 11:21:19 -0800, Pravin Shelar wrote:
>> One additional variable is not bad but look at what has happened in
>> vxlan_xmit_one(). There are already more than 20 variables defined. It
>> is hard to read code in this case.
>
> I agree that the function is horrible.
>
> What I was thinking about was separating the vxlan data and control
> plane. The vxlan data plane would perform encapsulation and
> decapsulation based on lwtunnel infrastructure and the rest of the
> "classical" vxlan would be just one of the users of that. Basically
> replacing vxlan_rdst by ip_tunnel_info, among other things.
>
> That would make the vxlan code much much cleaner.
>
I have patch which does something similar for geneve. But it is tricky
to do it for vxlan.

>> anyways I can add another variable to the function. I do not feel that
>> strongly about this.
>
> Me neither, actually. I prefer another variable but I won't oppose the
> patchset just based on that if you choose differently.
>
I have updated patches already. I will post it soon.
