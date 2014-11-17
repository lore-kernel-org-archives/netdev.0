From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] wireless: remove unnecessary sizeof(u8)
Date: Mon, 17 Nov 2014 06:56:27 +0100 (CET)
Message-ID: <828430032.148603.1416203787175.open-xchange@webmail.nmp.skynet.be>
References: <1415998553-12636-1-git-send-email-fabf@skynet.be> <CAGRGNgWqjsDu_mQK=_agBWjOequb4b7ffgCuxRH=9d72grDYtQ@mail.gmail.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	b43-dev <b43-dev@lists.infradead.org>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGRGNgWqjsDu_mQK=_agBWjOequb4b7ffgCuxRH=9d72grDYtQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 16 November 2014 at 23:33 Julian Calaby <julian.calaby@gmail.com> wrote:
>
>
> Hi Fabian,
>
> On Sat, Nov 15, 2014 at 7:55 AM, Fabian Frederick <fabf@skynet.be> wrote:
> > sizeof(u8) is always 1.
>
> I thought that sizeof(*variable) was preferred over sizeof(type), so
> shouldn't these be switched to that format instead?
>
> (I know that this is all no-op, but it should reduce the potential for
> highly unlikely bugs in the future. Also, the extra processing is
> compile-time not run-time.)
>
> Thanks,

Hi Julian,

Of course but char/u8/s8... allocations never use it and result would be the
same:
factor 1 multiplication.

Those rare occurrences (+- 30 in the whole kernel) where we have
sizeof(u8/s8) is ambiguous.

Having a patch removing it gives a pointer...
If the developer meant something else, he will be able to fix it.

Regards,
Fabian
