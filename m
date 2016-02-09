From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Wed, 10 Feb 2016 09:01:05 +1100
Message-ID: <CAGRGNgVwSPn4rc+19q7VVVL8V8zK=ubbF7in00HBYnsc1-WKWw@mail.gmail.com>
References: <CA+A7VXU9zoQZ5wM2Ranf7o9vUphGb0THkh8-TUM_1yD7aC30pQ@mail.gmail.com>
 <1455053802-13063-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455053802-13063-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Wed, Feb 10, 2016 at 8:36 AM, Jo=C3=A3o Paulo Rechi Vita
<jprvita@gmail.com> wrote:
> Provide an interface for the airplane-mode indicator be controlled fr=
om
> userspace. User has to first acquire the control through
> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole ti=
me
> it wants to be in control of the indicator. Closing the fd or using
> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.
>
> To change state of the indicator, the RFKILL_OP_AIRPLANE_MODE_CHANGE
> operation is used, passing the value on "struct rfkill_event.soft". I=
f
> the caller has not acquired the airplane-mode control beforehand, the
> operation fails.
>
> Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>

This looks sane to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

--=20
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
