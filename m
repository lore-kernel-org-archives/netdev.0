From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Fri, 11 Nov 2016 12:14:36 +0100
Message-ID: <20161111121436.56b214ab@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-3-git-send-email-pshelar@ovn.org>
        <20161109171018.69d08ff9@griffin>
        <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
        <20161110104703.7386ab29@griffin>
        <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
        <20161110193347.0e81d68b@griffin>
        <CAOrHB_AGV4x4G4QYFAaWNYgckvkDAS-prp65CgXfTqB4KoxHTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754579AbcKKLOk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 06:14:40 -0500
In-Reply-To: <CAOrHB_AGV4x4G4QYFAaWNYgckvkDAS-prp65CgXfTqB4KoxHTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016 11:21:19 -0800, Pravin Shelar wrote:
> One additional variable is not bad but look at what has happened in
> vxlan_xmit_one(). There are already more than 20 variables defined. It
> is hard to read code in this case.

I agree that the function is horrible.

What I was thinking about was separating the vxlan data and control
plane. The vxlan data plane would perform encapsulation and
decapsulation based on lwtunnel infrastructure and the rest of the
"classical" vxlan would be just one of the users of that. Basically
replacing vxlan_rdst by ip_tunnel_info, among other things.

That would make the vxlan code much much cleaner.

> anyways I can add another variable to the function. I do not feel that
> strongly about this.

Me neither, actually. I prefer another variable but I won't oppose the
patchset just based on that if you choose differently.

Thanks,

 Jiri
