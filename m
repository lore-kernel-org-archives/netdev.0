From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH][RESEND] drivers/base: export (un)register_memory_notifier
Date: Mon, 11 Feb 2008 07:22:54 -0800
Message-ID: <20080211152254.GC25505@kroah.com>
References: <200802111049.05478.ossthema@de.ibm.com>
	<1202724743.8276.2.camel@nimitz.home.sr71.net>
	<200802111147.51225.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <themann@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	Dave Hansen <haveblue@us.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200802111147.51225.ossthema@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 11, 2008 at 11:47:50AM +0100, Jan-Bernd Themann wrote:
> On Monday 11 February 2008 11:12, Dave Hansen wrote:
> > On Mon, 2008-02-11 at 10:49 +0100, Jan-Bernd Themann wrote:
> > > are you the right person to address this patch to?
> > 
> > You might want to check the top of the file. ;)
> > 
> > > --- a/drivers/base/memory.c
> > > +++ b/drivers/base/memory.c
> > > @@ -52,11 +52,13 @@ int register_memory_notifier(struct notifier_block *nb)
> > >  {
> > >          return blocking_notifier_chain_register(&memory_chain, nb);
> > >  }
> > > +EXPORT_SYMBOL(register_memory_notifier);
> > >  
> > >  void unregister_memory_notifier(struct notifier_block *nb)
> > >  {
> > >          blocking_notifier_chain_unregister(&memory_chain, nb);
> > >  }
> > > +EXPORT_SYMBOL(unregister_memory_notifier);
> > 
> > Is there a particular reason these can't be GPL?
> > 
> 
> I don't object to make them GPL. Greg, what do you think?

They should be _GPL to match the rest of the driver core.

Care to resend this?

thanks,

greg k-h
