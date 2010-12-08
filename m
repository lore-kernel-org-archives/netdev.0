From: Greg KH <gregkh@suse.de>
Subject: Re: [34/44] Limit sysctl_tcp_mem and sysctl_udp_mem
 initializers to prevent integer overflows.
Date: Wed, 8 Dec 2010 15:13:15 -0800
Message-ID: <20101208231315.GB8196@suse.de>
References: <AANLkTimTw3O-OM-5Cgv0ELNj8SmMjaaeMHMd2NNezxi7@mail.gmail.com>
	<20101208041656.GA2291@suse.de>
	<1291787445.5324.64.camel@edumazet-laptop>
	<20101208.082522.226789733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: pekkas@netcore.fi, eric.dumazet@gmail.com, kaber@trash.net,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org, w@1wt.eu,
        holt@sgi.com, kuznet@ms2.inr.ac.ru, akpm@linux-foundation.org,
        jmorris@namei.org, torvalds@linux-foundation.org,
        stable-review@kernel.org, alan@lxorguk.ukuu.org.uk, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101208.082522.226789733.davem@davemloft.net>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2010 at 08:25:22AM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 08 Dec 2010 06:50:45 +0100
> =

> > Le mardi 07 d=E9cembre 2010 =E0 20:16 -0800, Greg KH a =E9crit :
> >> On Tue, Dec 07, 2010 at 05:22:34PM -0800, Linus Torvalds wrote:
> >> > On Tue, Dec 7, 2010 at 4:04 PM, Greg KH <gregkh@suse.de> wrote:
> >> > >
> >> > > From: Robin Holt <holt@sgi.com>
> >> > >
> >> > > [ Problem was fixed differently upstream. -DaveM ]
> >> > =

> >> > Gaah. I'd really like to see more of a description for things like
> >> > this. A commit ID for the alternate fix, or at least a few words abo=
ut
> >> > the different fix or reason why upstream doesn't need the stable
> >> > commit.
> >> =

> >> I'll let David confirm this, he's the one who sent it to me :)
> > =

> > upstream uses commit 8d987e5c7510 (net: avoid limits overflow)
> > =

> > This commit is a bit more untrusive for stable kernels :
> > =

> > It depends on :
> > a9febbb4bd13 (sysctl: min/max bounds are optional)
> > 27b3d80a7b6a (sysctl: fix min/max handling in __do_proc_doulongvec_minm=
ax())
> =

> Yep, this is the case.  Greg, you can add a reference to:
> =

> a9febbb4bd13
> 27b3d80a7b6a
> 8d987e5c7510
> =

> in my "[ ... ]" in the commit message to clear this up.

Now added, thanks.

greg k-h
