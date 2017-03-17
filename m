From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Fri, 17 Mar 2017 07:42:24 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C5A53B@IRSMSX102.ger.corp.intel.com>
References: <1489678147-21404-8-git-send-email-elena.reshetova@intel.com>
	<1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jJpFwiDR_o=oarN_2vDr56cwQ=Bg-5NikUmDtxtzWnAcQ@mail.gmail.com>
	<20170316.121032.405930218798336643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"ishkamiel@gmail.com" <ishkamiel@gmail.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"kaber@trash.net" <kaber@trash.net>,
	"dwindsor@gmail.com" <dwindsor@gmail.com>
To: David Miller <davem@davemloft.net>, "keescook@chromium.org"
	<keescook@chromium.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170316.121032.405930218798336643.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> From: Kees Cook <keescook@chromium.org>
> Date: Thu, 16 Mar 2017 11:38:25 -0600
>=20
> > I am, of course, biased, but I think the evidence of actual
> > refcounting attacks outweighs the theoretical performance cost of
> > these changes.
>=20
> This is not theoretical at all.
>=20
> We count the nanoseconds that every packet takes to get processed and
> you are adding quite a bit.
>=20
> I understand your point of view, but this is knowingly going to add
> performance regressions to the networking code.

Should we then first measure the actual numbers to understand what we are t=
alking here about?=20
I would be glad to do it if you suggest what is the correct way to do measu=
rements here to actually reflect the real life use cases.=20

Best Regards,
Elena.
