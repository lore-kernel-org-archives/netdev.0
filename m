From: Jovi Zhang <bookjovi@gmail.com>
Subject: Re: [PATCH] net: mac80211: fix compilation warning
Date: Sat, 5 Mar 2011 21:52:00 +0800
Message-ID: <AANLkTimnSvBKSL6_d3RxufxUL_C9wCM+Fz66_B5Sc0KE@mail.gmail.com>
References: <1299108754-5492-1-git-send-email-bookjovi@gmail.com>
	<1299328260.4277.92.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:NETWORKING [WIREL..." <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299328260.4277.92.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 5, 2011 at 8:31 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Wed, 2011-03-02 at 18:32 -0500, bookjovi@gmail.com wrote:
>> From: Jovi Zhang <bookjovi@gmail.com>
>>
>> this commit fix compilation warning as following:
>> net/mac80211/tx.c:1753: warning: unused variable mppath
> [...]
>
> You clearly didn't try building this with CONFIG_MAC80211_MESH enable=
d.
>
Sorry, indeed, maybe should be like this:

+#ifdef CONFIG_MAC80211_MESH
=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mesh_path *mppath =3D NULL;
+#endif
