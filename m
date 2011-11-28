From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] 9p: Reduce object size with CONFIG_NET_9P_DEBUG
Date: Mon, 28 Nov 2011 09:14:00 -0800
Message-ID: <1322500440.2024.24.camel@Joe-Laptop>
References: <1321661394.5917.7.camel@Joe-Laptop>
	 <CAFkjPTmyn9POfTjYYjjYEaPt6M6Wdu-P=SEc=ZeTsbA+1=VraA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFkjPTmyn9POfTjYYjjYEaPt6M6Wdu-P=SEc=ZeTsbA+1=VraA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-28 at 09:10 -0600, Eric Van Hensbergen wrote:
> sorry, just got to reviewing this because of holidays.
>=20
> On Fri, Nov 18, 2011 at 6:09 PM, Joe Perches <joe@perches.com> wrote:
> > Reduce object size by deduplicating formats.
> >
> > Use vsprintf extension %pV.
> > Rename P9_DPRINTK uses to p9_debug, align arguments.
> > Add function for _p9_debug and macro to add __func__.
> > Add missing "\n"s to p9_debug uses.
> > Remove embedded function names as p9_debug adds it.
> > Remove P9_EPRINTK macro and convert use to pr_<level>.
> > Add and use pr_fmt and pr_<level>.
> >
> > $ size fs/9p/built-in.o*
> >   text    data     bss     dec     hex filename
> >  62133     984   16000   79117   1350d fs/9p/built-in.o.new
> >  67342     984   16928   85254   14d06 fs/9p/built-in.o.old
> >
> > Signed-off-by: Joe Perches <joe@perches.com>
>=20
> These changes seem reasonable enough, but since you only made changes
> in the fs/9p directory and not the net/9p directory which causes
> net/9p build to break with this patch.
>=20
> CC      net/9p/client.o
> /home/ericvh/src/linux/v9fs-devel/net/9p/client.c: In function
> =E2=80=98get_protocol_version=E2=80=99:
> /home/ericvh/src/linux/v9fs-devel/net/9p/client.c:84:3: error:
> implicit declaration of function =E2=80=98P9_DPRINTK=E2=80=99

Sorry 'bout that.
I'll fix it and resubmit later.
