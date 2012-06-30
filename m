From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Sat, 30 Jun 2012 21:18:04 +0300
Message-ID: <CANUX_P3kypkUv+-meABAOGa6GQ9cR5ugySJj+SjvVfCykCQuYQ@mail.gmail.com>
References: <1340786187.1911.24.camel@x61.thuisdomein>
	<1341062406.1911.76.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1341062406.1911.76.camel-uMdlDhfIn7prKue/0VVhAg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>
> On Wed, 2012-06-27 at 10:36 +0200, Paul Bolle wrote:
> > Every now and then, after resuming from suspend, the iwlegacy drive=
r
> > prints
> > =A0 =A0 iwl4965 0000:03:00.0: Queue 2 stuck for 2000 ms.
> > =A0 =A0 iwl4965 0000:03:00.0: On demand firmware reload
> >
> > I have no idea what causes these errors. But the code currently use=
s
> > wd_timeout in the first error. wd_timeout will generally be set at
> > IL_DEF_WD_TIMEOUT (ie, 2000). Perhaps printing for how long the que=
ue
> > was actually stuck can clarify the cause of these errors.
>

You may want to try this one:
http://www.spinics.net/lists/stable-commits/msg18110.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
