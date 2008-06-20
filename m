From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Fri, 20 Jun 2008 12:39:10 +0200
Message-ID: <20080620103910.GA21227@electric-eye.fr.zoreil.com>
References: <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net> <48593E35.1010409@e-teleport.net> <20080618201012.GA4019@electric-eye.fr.zoreil.com> <48598784.40306@e-teleport.net> <20080619204312.GA2160@electric-eye.fr.zoreil.com> <485B8542.7060204@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755618AbYFTKkN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <485B8542.7060204@e-teleport.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net> :
[...]
> But if I generate a paquet with a size more than around 3825, the dri=
ver=20
> don't send it and no paquet is send after, work again after an interf=
ace=20
> down/up and until no paquet > 3825.

Does it qualify as a regression ?

--=20
Ueimor
