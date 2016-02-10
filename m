From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Wed, 10 Feb 2016 17:07:24 +0100
Message-ID: <1455120444.4991.1.camel@sipsolutions.net>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
	 <1454946096-9752-9-git-send-email-jprvita@endlessm.com>
	 <1454947887.5325.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454947887.5325.8.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-02-08 at 10:11 -0600, Dan Williams wrote:
> I'd like to clarify a bit, so tell me if I'm correct or not.=C2=A0=C2=
=A0Using
> RFKILL_OP_AIRPLANE_MODE_CHANGE does not actually change any device
> state. It's just an indicator with no relationship to any of the
> registered rfkill switches, right?

Yes. I'm not sure I'm totally happy with this userspace API.

> I wonder if setting RFKILL_OP_AIRPLANE_MODE_CHANGE(true) shouldn't
> also
> softblock all switches, otherwise you can set airplane mode all day
> long with RFKILL_OP_AIRPLANE_MODE_CHANGE and it doesn't actually
> enable
> airplane mode at all?

No, this is kinda the point that you could implement your policy in
userspace now.

johannes
