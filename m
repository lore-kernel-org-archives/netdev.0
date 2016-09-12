From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 00/26] constify local structures
Date: Mon, 12 Sep 2016 15:52:08 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121548200.29099@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
 <20160911172105.GB5493@intel.com>
 <alpine.DEB.2.10.1609121051050.3049@hadrien> <20160912131625.GD957@intel.com>
 <877fah5j35.fsf@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, Mustafa Ismail <mustafa.ismail@intel.com>,
 Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
 kernel-janitors@vger.kernel.org, linux-fbdev@vger.kernel.org,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 tpmdd-devel@lists.sourceforge.net, linux-media@vger.kernel.org,
 linux-pm@vger.kernel.org, linux-can@vger.kernel.org,
 Julia Lawall <julia.lawall@lip6.fr>, Shiraz Saleem <shiraz.saleem@intel.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, netdev@vger.kernel.org,
 Chien Tin Tung <chien.tin.tung@intel.com>, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
 linux-renesas-soc@vger.kernel.org, linux-usb
To: Felipe Balbi <felipe.balbi@linux.intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <877fah5j35.fsf@linux.intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On Mon, 12 Sep 2016, Felipe Balbi wrote:

>
> Hi,
>
> Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com> writes:
> > On Mon, Sep 12, 2016 at 10:54:07AM +0200, Julia Lawall wrote:
> >>
> >>
> >> On Sun, 11 Sep 2016, Jarkko Sakkinen wrote:
> >>
> >> > On Sun, Sep 11, 2016 at 03:05:42PM +0200, Julia Lawall wrote:
> >> > > Constify local structures.
> >> > >
> >> > > The semantic patch that makes this change is as follows:
> >> > > (http://coccinelle.lip6.fr/)
> >> >
> >> > Just my two cents but:
> >> >
> >> > 1. You *can* use a static analysis too to find bugs or other issues.
> >> > 2. However, you should manually do the commits and proper commit
> >> >    messages to subsystems based on your findings. And I generally think
> >> >    that if one contributes code one should also at least smoke test changes
> >> >    somehow.
> >> >
> >> > I don't know if I'm alone with my opinion. I just think that one should
> >> > also do the analysis part and not blindly create and submit patches.
> >>
> >> All of the patches are compile tested.  And the individual patches are
> >
> > Compile-testing is not testing. If you are not able to test a commit,
> > you should explain why.
>
> Dude, Julia has been doing semantic patching for years already and
> nobody has raised any concerns so far. There's already an expectation
> that Coccinelle *works* and Julia's sematic patches are sound.
>
> Besides, adding 'const' is something that causes virtually no functional
> changes to the point that build-testing is really all you need. Any
> problems caused by adding 'const' to a definition will be seen by build
> errors or warnings.
>
> Really, just stop with the pointless discussion and go read a bit about
> Coccinelle and what semantic patches are giving you. The work done by
> Julia and her peers are INRIA have measurable benefits.
>
> You're really making a thunderstorm in a glass of water.

Thanks for the defense, but since a lot of these patches torned out to be
wrong, due to an incorrect parse by Coccinelle, combined with an
unpleasantly lax compiler, Jarkko does have a point that I should have
looked at the patches more carefully.  In any case, I have written to the
maintainers relevant to the patches that turned out to be incorrect.

julia
