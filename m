From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v4] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Fri, 21 Mar 2014 12:59:20 +0100
Message-ID: <1395403160.4164.0.camel@jlt4.sipsolutions.net>
References: <1395237113.4142.5.camel@jlt4.sipsolutions.net>
	 <1395383972-20372-1-git-send-email-behanw@converseincode.com>
	 (sfid-20140321_073942_314651_C3EB8ED0)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org,
	pageexec@freemail.hu,
	Jan-Simon =?ISO-8859-1?Q?M=F6ller?= <dl9pf@gmx.de>,
	=?ISO-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: behanw@converseincode.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395383972-20372-1-git-send-email-behanw@converseincode.com> (sfid-20140321_073942_314651_C3EB8ED0)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-20 at 23:39 -0700, behanw@converseincode.com wrote:
> From: Jan-Simon M=C3=B6ller <dl9pf@gmx.de>
>=20
> Replaced the use of a Variable Length Array In Struct (VLAIS) with a =
C99
> compliant equivalent. This is the original VLAIS struct.
>=20
> struct {
> 	struct aead_request     req;
> 	u8                      priv[crypto_aead_reqsize(tfm)];
> } aead_req;
>=20
> This patch instead allocates the appropriate amount of memory using a=
n char
> array.
>=20
> The new code can be compiled with both gcc and clang.

Applied.

johannes
