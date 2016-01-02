From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] net-qmi_wwan: Refactoring for qmi_wwan_bind()
Date: Sat, 02 Jan 2016 22:38:30 +0100
Message-ID: <87vb7bpsq1.fsf@nemi.mork.no>
References: <566ABCD9.1060404@users.sourceforge.net>
	<5686AE52.1020008@users.sourceforge.net>
	<5686AF55.5020801@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5686AF55.5020801@users.sourceforge.net> (SF Markus Elfring's
	message of "Fri, 1 Jan 2016 17:54:45 +0100")
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring@users.sourceforge.net> writes:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 17:32:07 +0100
>
> Reduce the scope for the local variable "desc" to one branch
> of an if statement.

This patch is harmless.  But is also pointless.

You could at least try to explain why this must be changed.  I'm not
interested in why you think it is better this way - I might agree with
that.  what I am interested in is the advantage changing the code gives
us.  Some analysis of the risk and work involved would also be nice.  I=
s
this change really worth it?

Personally I am convinced that I wasted any time I used writing this,
and you wasted any time you used reading it.  Sorry.

Note:  This patch would have been fine if it was a natural part of some
*improvement* of the driver, i.e. a bugfix or feaure addition. As a
standalone patch I see it as noise.

Please stop the noise and start writing something useful.  I'm sure you
can fix bugs instead.  Wouldn't that be more interesting?  More
challenging?  These mindless robotic code refactoring patches are reall=
y
best left for robots.




Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
