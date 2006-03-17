From: Hans-Peter Jansen <hpj@urpla.net>
Subject: Re: drivers/net/chelsio/sge.c: two array overflows
Date: Fri, 17 Mar 2006 13:19:19 +0100
Message-ID: <200603171319.20935.hpj@urpla.net>
References: <20060311013720.GG21864@stusta.de> <4415C87B.90107@chelsio.com> <441A011A.6010705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Bardone <sbardone@chelsio.com>, Adrian Bunk <bunk@stusta.de>,
	maintainers@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932100AbWCQMT3@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <441A011A.6010705@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[from the nitpick department..]

Hi Jeff, hi Scott,

Adrian wrote:
>The Coverity checker spotted the following two array overflows in=20
>drivers/net/chelsio/sge.c (in both cases, the arrays contain 3=20
>elements):

Am Freitag, 17. M=E4rz 2006 01:21 schrieb Jeff Garzik:
> Scott Bardone wrote:
> > Adrian,
> >
> > This is a bug. The array should contain 2 elements.
> >
> > Attached is a patch which fixes it.
> > Thanks.
> >
> > Signed-off-by: Scott Bardone <sbardone@chelsio.com>
>
> applied.  please avoid attachments and use a proper patch description
> in the future.  I had to hand-edit and hand-apply your patch.

where you wrote in kernel tree commit=20
347a444e687b5f8cf0f6485704db1c6024d3:
This is a bug. The array should contain 2 elements.  Here is the fix.

If I'm not completely off the track, you both committed a description=20
off by one error: since the patch doesn't change the array size, it's=20
presumely=B9 still 3 elements, where index 2 references the last one.

Here's hopefully a better patch description:
=46ixed off by one thinko in stats accounting, spotted by Coverity=20
checker, notified by Adrian "The Cleanman" Bunk.

SCR,
Pete

=B9) otherwise, it's still off by one..
