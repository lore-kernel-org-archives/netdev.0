From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Thu, 21 Apr 2011 09:49:43 -0700
Message-ID: <1303404583.24766.63.camel@Joe-Laptop>
References: <1303322263-18991-10-git-send-email-mcarlson@broadcom.com>
	 <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
	 <1303374696.3685.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303374696.3685.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-04-21 at 10:31 +0200, Eric Dumazet wrote:
> Le mercredi 20 avril 2011 =C3=A0 23:39 -0700, Joe Perches a =C3=A9cri=
t :
> > Using a bitmap instead of separate u32 flags allows a consistent, s=
impler
[]
> Use an enum ?

No strong preference.
If it's an enum .c file will change.
=09
> Why first value is 1 and not 0 ?

Should be 0.

> > +#define TG3_FLAGS			74	/* Set to number of flags */
> Also you need to make TG3_FLAGS be (last_flag_value + 1) or you could
> miss one long in bitmap.

Right.  Thanks for comments Eric.
I'll wait for Matt to comment before resubmitting.
