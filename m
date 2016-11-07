From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] vxlan: hide unused local variable
Date: Mon, 07 Nov 2016 23:21:50 +0100
Message-ID: <2394498.yAioIp78MI@wuerfel>
References: <20161107211017.857340-1-arnd@arndb.de> <CAOrHB_BRnCmka_cQ1ALnOC1Yta7c8_KWrQ7tzr2tX2fbvOjs7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrHB_BRnCmka_cQ1ALnOC1Yta7c8_KWrQ7tzr2tX2fbvOjs7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, November 7, 2016 2:16:30 PM CET Pravin Shelar wrote:
> On Monday, November 7, 2016, Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > A bugfix introduced a harmless warning in v4.9-rc4:
> >
> > drivers/net/vxlan.c: In function 'vxlan_group_used':
> > drivers/net/vxlan.c:947:21: error: unused variable 'sock6'
> > [-Werror=unused-variable]
> >
> > This hides the variable inside of the same #ifdef that is
> > around its user. The extraneous initialization is removed
> > at the same time, it was accidentally introduced in the
> > same commit.
> >
> > Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de <javascript:;>>
> > ---
> 
> 
> I have already submitted patch to fix this issue.
> 
> https://patchwork.ozlabs.org/patch/691588/

You have tagged those seven patches for net-next which seems
appropriate, but as I wrote above the commit that introduced
it was merged between -rc3 and -rc4, so I think we still need a
fix for v4.9, right?

	Arnd
