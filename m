From: David Woodhouse <dwmw2@infradead.org>
Subject: RE: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 14:56:36 +0000
Message-ID: <1108047396.19262.537.camel@hades.cambridge.redhat.com>
References: <36282A1733C57546BE392885C06185927377BE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <36282A1733C57546BE392885C06185927377BE@chaos.tcs.tcs-sec.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-02-10 at 09:37 -0500, Chad Hanson wrote:
> In your example of a process watching daemon, why would this daemon wan=
t to
> spoof the credentials of the watched process? I can think of two exampl=
es.

Perhaps I misunderstand the intent of userspace AUDIT_WRITE. Can you
provide examples of why you _wouldn't_ want to let a d=C3=A6mon which is
already sending random unvetted AUDIT_WRITE messages also specify the
loginuid on _those_ messages?

--=20
dwmw2
