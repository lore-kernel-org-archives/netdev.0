From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/9] rfkill: Create "rfkill-airplane_mode" LED trigger
Date: Thu, 18 Feb 2016 21:08:41 +0100
Message-ID: <1455826121.2084.17.camel@sipsolutions.net>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
	 <1454946096-9752-8-git-send-email-jprvita@endlessm.com>
	 (sfid-20160208_164147_435264_67EE08E5)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454946096-9752-8-git-send-email-jprvita@endlessm.com> (sfid-20160208_164147_435264_67EE08E5)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-02-08 at 10:41 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
> This creates a new LED trigger to be used by platform drivers as a
> default trigger for airplane-mode indicator LEDs.
>=20
> By default this trigger will fire when RFKILL_OP_CHANGE_ALL is called
> for all types (RFKILL_TYPE_ALL), setting the LED brightness to
> LED_FULL
> when the changing the state to blocked, and to LED_OFF when the
> changing
> the state to unblocked. In the future there will be a mechanism for
> userspace to override the default policy, so it can implement its
> own.
>=20
> This trigger will be used by the asus-wireless x86 platform driver.

Just one comment - I think you should be consistent with the _ vs - and
just use "rfkill-airplane-mode" as the name.

johannes
