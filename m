From: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 06:48:00 +0000
Message-ID: <BL2PR07MB23064356EA2492675AC980A78DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912163928.GK8812@leon.nu>
 <CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
 <CY4PR11MB17202A542AC07CBA4A65E93697FF0@CY4PR11MB1720.namprd11.prod.outlook.com>,<20160913060545.GN8812@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160913060545.GN8812-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> While this might work, I personally dislike it as I find it
>> counter-intuitive when going over the code -
>> I don't expect driver to locally modify the inclusion path.
>> Besides, we're going to [eventually] a whole suite of drivers based
>> on the qed module, some of which would reside under drivers/scsi;
>> Not sure it's best to have 3 or 4 different drivers privately include th=
e
>> same directory under a different subsystem.

> I agree with you that orcdma's way can be valuable for small drivers.

> Orcmda has small shared headers set and doesn't need to change them rapid=
ly
> to support different devices.

> I thought to place them in similar directory to include/soc/* and remove
> from include/linux/. We have include/rdma/ and it looks like a good
> candidate.

I'm perfectly fine with relocating those to a different directory under inc=
lude/,
although using 'rdma' doesn't sound like a good fit [as the headers would b=
e
included by ethernet, scsi and rdma drivers].=20
Are there good existing alternatives?

Regardless, I don't believe this should be part of the initial submission,
as it would involve in relocating existing networking headers as well.
I think we can move those at leisure later on.

[We're in the middle of transitioning our e-mails from qlogic -> cavium,
so sorry if things become corrupted]=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
