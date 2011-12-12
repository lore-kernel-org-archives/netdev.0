From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 09:33:44 -0800
Message-ID: <20111212173344.GA10162@kroah.com>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
 <20111212150255.GA7506@kroah.com>
 <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
 <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
 <1323704494.1765.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAEnQRZAt0X6cxGLgLUVTB9rzLKVYLEnh=azS9WOyKAkUZEpj4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	adobriyan@gmail.com
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAEnQRZAt0X6cxGLgLUVTB9rzLKVYLEnh=azS9WOyKAkUZEpj4g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2011 at 06:42:59PM +0200, Daniel Baluta wrote:
> On Mon, Dec 12, 2011 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 12 d=E9cembre 2011 =E0 17:39 +0200, Daniel Baluta a =E9cri=
t :
> >
> >> Ok, for the moment it seems to be a bad idea. But my intention is
> >> to integrate kref to networking code, and then to write a general
> >> debugging tool for refs.
> >>
> >> Tracking down reference count problems is hard, and this tool can
> >> really help everyone.
> >
> > I dont think kref will help you that much, because its used everywh=
ere.
> >
> > Adding a general debugging tool will provide too much noise.
> >
> > Instead, we (network dev) add debugging points where we want.
>=20
> Yes, but you have to do this each time you start debugging, for a
> particular referenced counted object.
>=20
> We must find a clever solution to avoid the noise. (e.g use
> /proc, /sysfs, /debugfs options to trigger dumping info for
> some/all objects with a certain state).

Then use the dynamic debug infrastructure, which is there to help you
try to handle this type of debugging on-the-fly.

But again, it's not a kref issue, sorry.

greg k-h
