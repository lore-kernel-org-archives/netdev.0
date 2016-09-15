From: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 02/11] Add RoCE driver framework
Date: Thu, 15 Sep 2016 05:11:03 +0000
Message-ID: <BL2PR07MB23060C776EDAE92B84FCFB768DF00@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160914130032.GB26069@leon.nu>
 <BL2PR07MB23066BBC4A019365A632E2FA8DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160915043716.GD26069@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal Kalderon" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160915043716.GD26069-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > If you want dynamic prints, you have two options:
> > > 1. Add support of ethtool to whole RDMA stack.
> > > 2. Use dynamic tracing infrastructure.
> >
> > > Which option do you prefer?
> > Option 3 - continuing this discussion. :-)
>=20
> Sorry,
> I was under impression that you want this driver to be merged, but it loo=
ks like It
> was incorrect assumption. Let's continue discussion.

No, this is an RFC - there's no chance for *this* to merge, but this is exa=
ctly
the right time to discuss this sort of stuff.

> > Perhaps I misread your intentions - I thought that by dynamic debug
> > you meant that all debug in RDMA should be pr_debug() based, and
> > therefore my objection regarding the ease with which users can
> > configure it.
>=20
> It is not for all RDMA, but in your proposed driver. You are adding this =
"debug"
> module argument to your module.

I don't get your answer.=20
I made a generic remark [and actually one in favor of your arguments],
and instead of saying something meaningful you bash the driver.

> > If all you meant was 'dynamically set' as opposed to 'statically set'
> > then I agree that having that sort of configurability is preferable
> > [Even though end-user would still probably prefer a module parameter
> > for reproductions; As the name implies, 'debug' isn't meant to be used
> > in other situations].
>=20
> We are not adding code just for fun, but for a real reason, and especiall=
y
> interfaces which will be visible to user.
>=20
> The overall expectation from the driver's authors that they are submittin=
g driver
> which doesn't have bringup issues. For real life scenarios, where the bug=
s will be
> reveled after some time of usage, this global debug is useless.

This has nothing to do with bringup; Real drivers are experiencing issues y=
ears after
they're productized.

> > Do notice you would be harming user-experience of reproductions though
> > - as it would have to follow different mechanisms to open debug prints
> > of various qed* components.
>=20
> I don't understand this point at all. Do you think that it is normal to a=
sk user to
> debug your driver? Is this called "user-experience"?

No, I call this 'user involved in fixing the driver' - it has nothing to do=
 with
user-experience. Sometimes user have specifics in his system that can't
be easily identified and thus lab reproductions fail, and the user assists
in the reproduction. While I never claimed this is good practice it does ha=
ppen.

> As a summary, I didn't see in your responses any real life example where =
you will
> need global debug level for your driver.

Not sure what you you're expecting - a list of BZs /private e-mails where
user reproductions were needed?
You're basically ignoring my claims that such are used, instead wanting
"evidence". I'm not going to try and produce any such.

Doug - I think we need a definite answer from you here; Doesn't look like
this discussion would bear any fruit.
If a debug module parameter is completely unacceptable, we'd remove it
[regardless of what I think about it].

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
