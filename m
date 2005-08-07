From: =?ISO-8859-1?Q?Espen_Fjellv=E6r_Olsen?= <espenfjo@gmail.com>
Subject: Re: 2.6.13-rc4-mm1: iptables DROP crashes the computer
Date: Sun, 7 Aug 2005 23:40:53 +0200
Message-ID: <7aaed09105080714402bcbddc6@mail.gmail.com>
References: <7aaed091050807100843454603@mail.gmail.com>
	<7aaed09105080710121bba1b5b@mail.gmail.com>
	<20050807172333.GF3513@stusta.de> <42F65513.3080409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux <linux-kernel@vger.kernel.org>, discuss@x86-64.org,
	Adrian Bunk <bunk@stusta.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42F65513.3080409@trash.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On 07/08/05, Patrick McHardy <kaber@trash.net> wrote:
> Could be related to the refcnt underflow with conntrack event
> notifications enabled. If you have CONFIG_IP_NF_CONNTRACK_EVENTS
> enabled please try this patch.
>=20

I can confirm that that patch solved my problems, thank you :)

--=20
Mvh / Best regards
Espen Fjellv=E6r Olsen
espenfjo@gmail.com
Norway
