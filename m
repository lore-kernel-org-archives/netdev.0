From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: waiting for ppp0 to become free (Re: ppp0 out of control)
Date: Sun, 30 Jan 2005 15:39:56 +0000
Message-ID: <1106857106.14782.56.camel@localhost.localdomain>
References: <20050121144444.GA2100@roxor.be>
	 <20050126094422.GA31040@lk8rp.mail.xeon.eu.org>
	 <20050126203118.GB3705@roxor.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Janos Farkas <jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Aur=E9lien_G=C9R=D4ME?= <ag@roxor.be>
In-Reply-To: <20050126203118.GB3705@roxor.be>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2005-01-26 at 20:31, Aur=C3=A9lien G=C3=89R=C3=94ME wrote:
> Yep, 2.6.8.1 works fine, this issue appears on 2.6.9 and 2.6.10. I
> switched to a Debian 2.6.10 kernel for security reasons, and
> the issue has not come yet. I had a glance at the changelog and
> saw some network related patches. This is the -as patchset, see
> <http://kerneltrap.org/node/4545> about it.


2.6.9 changed the tty hangup code and this did introduce a problem with
serial ppp ignoring hangups. That was fixed in 2.6.9-ac and the fix is
in 2.6.10. If you are using serial ppp the 2.6.8 to 9 breakage is known
but the 2.6.10 case should be fine.

Alan
