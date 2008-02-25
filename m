From: "Dave Young" <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Mon, 25 Feb 2008 16:26:57 +0800
Message-ID: <a8e1da0802250026u6220957as9ecf96ff5aa17303@mail.gmail.com>
References: <47666E1F.2000902@mizi.com>
	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>
	 <a8e1da0802242334v23a60cb4q1953b5caf5eb9947@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: louis-6CAt/Z4uMM0@public.gmane.org, "Marcel Holtmann" <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Linux Kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a8e1da0802242334v23a60cb4q1953b5caf5eb9947-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry, bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org was missed in cc

On Mon, Feb 25, 2008 at 3:34 PM, Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> On Mon, Feb 25, 2008 at 3:30 PM, Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>  > Quote mail from louis-6CAt/Z4uMM0@public.gmane.org :
>  >
>  >  2007/12/17 Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>:
>  >
>  >
>  > > Hello everybody,
>  >  >
>  >  >  I attached two patches. the first one(bluez-kernel-forcesco.patch) is to
>  >  >  force using HCI_OP_ADD_SCO instead of HCI_OP_SETUP_SYNC_CONN, and the
>  >  >  second one is to handle SCO connection complete event but its request
>  >  >  was ESCO.
>  >  >
>  >  >  1.
>  >  >  I'm developing bluetooth functions in my linux phone project, and I'm
>  >  >  using bluez for my job. I've tested lots of headsets, and found that I
>  >  >  coudn't connect SCO channel with HCI_OP_SETUP_SYNC_CONN in some old
>  >  >  headsets. I could connect SCO channel with HCI_OP_ADD_SCO in this case.
>  >  >  however, there is no api to force using SCO instead of ESCO in bluez. so
>  >  >  I added SCO_FORCESCO to handle this old headsets
>  >  >
>  >  >  2.
>  >  >  When I tried to connect SCO channel with
>  >  >  HCI_OP_SETUP_SYNC_CONN(LINK_TYPE_ESCO), some bluetooth headsets responds
>  >  >  with LINK_TYPE_SCO because it did not support ESCO. But bluez couldn't
>  >  >  handle this situation, and patch_hci_event.c is for this.
>  >  >
>  >  >
>  >  >  BRs
>  >  >  Louis JANG
>  >  >
>  >  >
>  >
>  >  Reply from bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org:
>  >
>  >  On Mon, Feb 25, 2008 at 2:43 PM, Brad Midgley <bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>  >  > Louis
>  >
>  > >
>  >  >
>  >  >  >  When I tried to connect SCO channel with
>  >  >  >  HCI_OP_SETUP_SYNC_CONN(LINK_TYPE_ESCO), some bluetooth headsets responds
>  >  >  >  with LINK_TYPE_SCO because it did not support ESCO. But bluez couldn't
>  >  >  >  handle this situation, and patch_hci_event.c is for this.
>  >  >
>  >
>  > >  Marcel looked at this patch and came back with the comments below. Can
>  >  >  you revisit it? I think some other people are seeing the same issues.
>  >  >  The patch won't go upstream until Marcel likes it.
>  >  >
>  >  >  the patch you sent me is fully broken. First of all the coding style
>  >  >  is wrong. Does nobody have learned this by now? I always look for that
>  >  >  first before even reading the patch. Second the case where an
>  >  >  ESCO_LINK returns NULL is broken and will fall over and crash.
>  >  >
>  >  >  --
>  >  >  Brad
>  >  >
>  >
>  >
>  >  I ever asked marcel about the coding style. please see following thread:
>  >  http://lkml.org/lkml/2008/1/22/91
>  >
>  >  I think the style problem marcel said is
>  >  1. using kernel codeing style
>  >  2. marcel's style
>  >  container_of or get_user_data calls at the top of the variable declaration
>  >  using the empty lines to seperate code blocks
>  >
>  >  Please rework your patch and resend if you fixed them.
>  >
>  >  BTW, please use the new bluetooth mailing list for kerne issue.
>  >  linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>  >
>  >  (Thanks for andrew and davem)
>
>  On bugzilla, bug 9871 are same problem as yours.
>
>  add davem and netdev in cc-list
>
>  >
>  >  Regards
>  >  dave
>  >
>  >  Regards
>  >  dave
>  >
>
-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
