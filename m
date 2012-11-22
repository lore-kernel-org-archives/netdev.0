From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all
	headers before an ethernet header
Date: Thu, 22 Nov 2012 09:28:36 +0100
Message-ID: <3602626.rWyvU1cq5r@bentobox>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
 <8108710.8oNxxR0rRd@sven-laptop.home.narfation.org>
 <E603DC592C92B54A89CEF6B0919A0B1CA7D5A6CC87@SOLO.hq.farsitecommunications.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1882661.efN5j1IJCI";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: "fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org" <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org" <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>,
 "jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org" <rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>,
 "ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "lindner_marek-LWAfsSFWpa4@public.gmane.org" <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>
To: Kevin Curtis <Kevin.Curtis-AP8L3A0T/wRBDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CA7D5A6CC87-uLMF5YoEu3cpvdBnIIuIUrTzKHr1x449ALKb+EK9MtIAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--nextPart1882661.efN5j1IJCI
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Thursday 22 November 2012 08:12:38 Kevin Curtis wrote:
> >> Agree. But we should get this message also to the other guys
> 
> What message would this be?
> Are you advocating a different use of #pragma pack()?

David started this discussion and his statement was:

> The __packed attribute is an abstraction of the actual syntax the 
> compiler uses, if it is supported at all.
> 
> Therefore, you can't just unconditionally use the #pragma, and you 
> would need to use some kind of similar compiler abstraction for it.

So yes, it sounds to me like "don't use #pragma but think about some 
abstraction".

Kind regards,
	Sven
--nextPart1882661.efN5j1IJCI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQreI0AAoJEF2HCgfBJntGoBcQAIY7c2z8xYjk4ff4LlQ3/cZT
3XeMujBuFzHuK2uYq0MtM6yvgPjFAiviNzUjgUv5457QQlYsrm9PXHQ/vvT63htB
xJi0V1dFwjokCBCOCdK4iKtPvGe+jDZzv3igBFhSB7htPTwOQWwP/QNRnzfyGo78
HrNg0gpTsniMzPWNOxEY63R3QQ6VqnqifpmaUOXYPYbrVryclkl4KlKC/daTG2OJ
PAOBv5pwu5F10KM+Oajyy9vx8uBjK74mpTvNhZQBADFLhSyHrdjKNjGyGcy64s0Q
JA41/lroR7R1YnlSkd7UwJmpvF+LpzPQH3FCHVvCVl326bhwrwU0G7jkarb0HaPC
85fDye+B2iCuOfk5wWZTt6RHRLCUgvsS4RZsV+6E6nfJnb41o1A8uCJVRk5yrWUp
t9PzNM7eZMiDb+e0izRAKnOAFlk8Thzou4n6tvC+YybZtnlKzduPUR1V+5hSF9p1
4C1fbPKNOjL9zqfMB5qUv+IhUrJ9lc9He25dpR95Vg6WFbkH5EC7OJ7nOKVB76WM
3XpHIb96KoLZfP2TQDPzaR6tVuVpGsT0eIgE4X11CWPr2QBKmbXJoRlwMv5CDG6e
8utkKPJhKk9kUXGAeHHuiPGLJSPdLCyUaHkfTeJBZkn1jGndQ+96T5WdA1pa3wxp
cwxG0FImhPmEZ2oqWKX+
=JqPT
-----END PGP SIGNATURE-----

--nextPart1882661.efN5j1IJCI--
