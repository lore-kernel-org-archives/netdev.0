From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 16:41:34 +0100
Message-ID: <1323704494.1765.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	 <20111212150255.GA7506@kroah.com>
	 <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
	 <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, adobriyan@gmail.com
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 12 d=C3=A9cembre 2011 =C3=A0 17:39 +0200, Daniel Baluta a =C3=A9=
crit :

> Ok, for the moment it seems to be a bad idea. But my intention is
> to integrate kref to networking code, and then to write a general
> debugging tool for refs.
>=20
> Tracking down reference count problems is hard, and this tool can
> really help everyone.

I dont think kref will help you that much, because its used everywhere.

Adding a general debugging tool will provide too much noise.

Instead, we (network dev) add debugging points where we want.
