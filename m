From: Olaf Hering <olh@suse.de>
Subject: Re: 2.6.8, pppd: Terminating connection due to lack of activity.
Date: Thu, 19 Aug 2004 20:28:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819182851.GA11063@suse.de>
References: <20040819175017.GA10513@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040819175017.GA10513@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Thu, Aug 19, Olaf Hering wrote:

> Hello,
>=20
> 2.6.8.1 terminates a pppoe connection after 5 minutes, even if there is
> still activity. This does not happen 2.6.8-rc2-bk13. I'm not sure if it
> is related to .config option, probably not.
>=20
> There is nothing in the logs, only the kernel was changed.


Aug 19 20:23:32 ibook kernel: ppp_ioctl(666) pppd(3488):c0,j104988 jiffie=
s 104988 last_xmit 0 last_recv 0 idle.xmit_idle 104 idle.recv_idle 104 HZ=
 1000
Aug 19 20:26:48 ibook pppd[3488]: Terminating connection due to lack of a=
ctivity.
Aug 19 20:26:48 ibook pppd[3488]: Couldn't increase MTU to 1500
Aug 19 20:26:48 ibook pppd[3488]: Couldn't increase MRU to 1500
Aug 19 20:26:48 ibook kernel: ppp_ioctl(666) pppd(3488):c0,j301149 jiffie=
s 301149 last_xmit 0 last_recv 0 idle.xmit_idle 301 idle.recv_idle 301 HZ=
 1000
Aug 19 20:26:48 ibook pppd[3488]: Connection terminated.
Aug 19 20:26:48 ibook pppd[3488]: Connect time 8.3 minutes.
Aug 19 20:26:48 ibook pppd[3488]: Sent 49673 bytes, received 404498 bytes.
Aug 19 20:26:50 ibook pppd[3488]: Script /etc/ppp/ip-down finished (pid 8=
122), status =3D 0x0
Aug 19 20:27:33 ibook pppd[3488]: Starting link
Aug 19 20:27:33 ibook pppd[3488]: PPP session is 1358


last_xmit/last_recv remains zero for some reasons.

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
