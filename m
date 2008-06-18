From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Wed, 18 Jun 2008 22:10:12 +0200
Message-ID: <20080618201012.GA4019@electric-eye.fr.zoreil.com>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net> <48593E35.1010409@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756449AbYFRULY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48593E35.1010409@e-teleport.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net> :
[...]
> This correction seems to work.
>
> I read somewhere pci_free_consistent (in velocity_free_dma_rings) cou=
ldn't=20
> be use in a spin_lock.

Yup.

> When I move velocity_free_rings outside the spin_lock, error desappea=
re but=20
> data transfert doesn't work after the mtu change.
> When I add velocity_give_many_rx_descs all work.

I have updated http://userweb.kernel.org/~romieu/via-velocity/2.6.26-rc=
6/
accordingly. Can you check whether it is fine or not ?

--=20
Ueimor
