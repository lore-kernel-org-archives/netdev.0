From: "David S. Miller" <davem@redhat.com>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 06:10:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716061013.64f14a04.davem@redhat.com>
References: <20030716092354.GC24077@suse.de>
	<20030716054255.1922d299.davem@redhat.com>
	<20030716125910.GB10817@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mads Martin =?ISO-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
In-Reply-To: <20030716125910.GB10817@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 14:59:10 +0200
Mads Martin J=F8rgensen <mmj@suse.de> wrote:

> > That is why all of this is rediculious.
>=20
> Problem is some of these includes are different on different archs, and
> causes the thing to miscompile. How to fix that then?

Nothing arch specific resides in linux/if.h :-)

This means the problem eminates from asm/*.h headers which is
where the fixes belong.

What exactly is the error you get on ia64?
