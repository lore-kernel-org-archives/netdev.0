From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v7 03/33] net: set name_assign_type in alloc_netdev()
Date: Thu, 10 Jul 2014 15:27:07 +0200
Message-ID: <87zjghfiok.fsf@nemi.mork.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	<1404980258-30853-4-git-send-email-teg@jklm.no>
	<87tx6ph8u5.fsf@nemi.mork.no>
	<CAG-2HqVvW2dh5y8xn9v-B29ohFTcPGgY3NY-P5y_xZu0SGgG3g@mail.gmail.com>
	<87ha2ph2ow.fsf@nemi.mork.no>
	<CAG-2HqXZe26RVnWCKpCfkPmP+OOA5fnrUL-o3+258KLTHPoxOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqXZe26RVnWCKpCfkPmP+OOA5fnrUL-o3+258KLTHPoxOA@mail.gmail.com>
	(Tom Gundersen's message of "Thu, 10 Jul 2014 15:02:41 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Gundersen <teg@jklm.no> writes:

> What I suggest to do is:
>
> Leave NET_NAME_UNKNOWN in alloc_etherdev() (and any similar
> constructs), but in the cases where we know that the final name set
> before netdev_register() is some template, I'd still set this to
> NET_NAME_ENUM as we do now to make it clear which cases have been
> reviewed. So the patchset does not change much, but it would eliminat=
e
> any risk of false positives.
>
> Does that sound reasonable to you?

Yes, sure.  Although I'm not at all convinced about the value.  But I
don't need to be, as that is not for me to decide :-)



Bj=C3=B8rn
