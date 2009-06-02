From: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 09/10] ieee802154: add serial dongle driver
Date: Tue, 2 Jun 2009 18:43:35 +0400
Message-ID: <20090602144335.GC13088@build.ossfans.org>
References: <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-10-git-send-email-dbaryshkov@gmail.com> <20090601162732.4a070c43@lxorguk.ukuu.org.uk> <20090601202946.GB7143@doriath.ww600.siemens.net> <20090601225205.1e7e8944@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090601225205.1e7e8944-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > C&P from drivers/bluetooth/hci-ldisc.c, around line 466. We had problems
> > working with low-latency unset.
> 
> The bluetooth one needs killing too. I will do that tomorrow ...
> 
> How many releases ago - the entire tty buffering layer has been rewritten
> over time. tty->low_latency requires driver specific support that most
> don't have. Also as of 2.6.30rc you'll get debug spew if you misuse it.
> 
> If you still need it we need to know why.

As we're tested it here, we don't need tty->low_latency anymore.
So that can go away. Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
