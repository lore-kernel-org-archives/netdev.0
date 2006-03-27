From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32bit compat for rtnetlink wireless extensions?
Date: Mon, 27 Mar 2006 23:10:44 +0200
Message-ID: <200603272310.44692.arnd@arndb.de>
References: <200603261408.48766.arnd@arndb.de> <20060327184242.GC31478@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751443AbWC0VLy@vger.kernel.org>
To: jt@hpl.hp.com
In-Reply-To: <20060327184242.GC31478@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Monday 27 March 2006 20:42 schrieb Jean Tourrilhes:
> =A0=A0=A0=A0=A0=A0=A0=A0Actually, when things are passed over RtNetli=
nk, the pointer
> is removed, and the content of IW_HEADER_TYPE_POINT is moved to not
> leave a gap.

Ah, that makes sense, thanks for the explanation.

So if the wireless ioctl interface ever got retired, that code could
get simplified a lot to just pass around a flat data structure, right?

	Arnd <><
