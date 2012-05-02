From: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Wed, 2 May 2012 04:38:36 +0200
Message-ID: <20120502023836.GW3157@wantstofly.org>
References: <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org>
 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
 <20120501125102.GN3157@wantstofly.org>
 <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
 <4FA089F9.1020602@erley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lautriv <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
To: Pat Erley <pat-lkml-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FA089F9.1020602-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2012 at 09:12:25PM -0400, Pat Erley wrote:

> >--- a/drivers/net/wireless/mwl8k.c
> >+++ b/drivers/net/wireless/mwl8k.c
> >@@ -5225,6 +5225,7 @@ static void mwl8k_finalize_join_worker(struct work_struct *work)
> >  }
> >
> >  enum {
> >+	MWL8361P = 0,
> >  	MWL8363 = 0,
> >  	MWL8687,
> >  	MWL8366,
> 
> I'm not an expert, but isn't this giving both 8361P and 8363 the
> same values in the enum?

Yeah, this is broken.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
