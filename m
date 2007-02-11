From: Maxim <maximlevitsky@gmail.com>
Subject: Re: [PATCH] [004] dmfe : Add suspend/resume support
Date: Sun, 11 Feb 2007 23:05:34 +0200
Message-ID: <45cf8524.034e66ed.1dc4.638d@mx.google.com>
References: <549393.8054.qm@web38506.mail.mud.yahoo.com> <20070209205451.GA3949@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, tori@unhappy.mine.nu,
	netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>, pavel@ucw.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:10311 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbXBKVFm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Feb 2007 16:05:42 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2004506nfa
        for <netdev@vger.kernel.org>; Sun, 11 Feb 2007 13:05:40 -0800 (PST)
In-Reply-To: <20070209205451.GA3949@ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 22:54:52 Pavel Machek wrote:
> Hi!
>
> > From: Maxim Levitsky <maximlevitsky@yahoo.com>
> > Subject: [PATCH] [NETDEV] [004] dmfe : Add suspend/resume support
> >
> > Adds support for suspend/resume
>
> Patch looks ok, but your mailer damaged it heavily.
>
> > --- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07
> > 18:46:13.000000000 +0200 +++
> > linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:50:52=
=2E000000000
> > +0200 @@ -55,9 +55,6 @@
> > =A0
> > =A0 =A0 =A0TODO
> > =A0
> > - =A0 =A0Implement pci_driver::suspend() and pci_driver::resume()
> > - =A0 =A0power management methods.
> > -
> > =A0 =A0 =A0Check on 64 bit boxes.
> > =A0 =A0 =A0Check and fix on big endian boxes.
> > =A0
> > @@ -2027,11 +2024,59 @@ static struct pci_device_id dmfe_pci_tbl
> > =A0MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
> > =A0
> > =A0
> > +
> > +static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t stat=
e)
> > +{
>
> 							Pavel


Hi , thanks for reply , I will send them again, and this time I will ch=
eck=20
that mailer doesn't mess with patches.

I fixed word wrap problem.

I also want to note that my address is now maximlevitsky@gmail.com , th=
e=20
address I took recently because yahoo is only aviable via webmail
and it is not good for patches.

Thanks for reply,=20

regards , Maxim Levitsky

