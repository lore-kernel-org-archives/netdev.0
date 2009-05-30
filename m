From: Minoru Usui <mi.usui@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 07:22:37 +0900
Message-ID: <b10243b50905301522t42aafaffxbf5934388af3df93@mail.gmail.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:43684 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZE3WWg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 18:22:36 -0400
Received: by qyk36 with SMTP id 36so701485qyk.33
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 15:22:37 -0700 (PDT)
In-Reply-To: <1243688628.3966.126.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, jamal

2009/5/30 jamal <hadi@cyberus.ca>
>
> On Sat, 2009-05-30 at 14:45 +0200, Jarek Poplawski wrote:
> > On Sat, May 30, 2009 at 08:31:23AM -0400, jamal wrote:
>
> > > Remeber, you could have NLM_F_EXCL|NLM_F_CREATE to indicate "crea=
te this
> > > thing if it doesnt exist; if it exists =A0it is an error"
> > > If it doesnt exist we will enter that (tp =3D=3D NULL) path
> > > also fh will be 0 =3D=3D> So you will never enter the code
> > > path you are refering to.
> > > If it exists (i.e you found it) and you enter the code path you r=
efer
> > > to, then you surely dont want to destroy it if NLM_F_EXCL is set.
> >
> > I mean we don't want to link it again or destroy after ->change() e=
rr
> > if we run replace (n->nlmsg_type =3D=3D RTM_NEWTFILTER &&
> > (n->nlmsg_flags&NLM_F_CREATE)).
>
> excellent point: an additional flag is needed then
> n->nlmsg_flags& (NLM_F_CREATE|NLM_F_EXCL).
> Minoru, please add this change in the patch before testing...

OK.
I'll do it after understanding above code.
