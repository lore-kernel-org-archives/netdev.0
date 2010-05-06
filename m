From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 11:19:33 +0300
Message-ID: <20100506081933.GF10044@redhat.com>
References: <20100504230225.GP8323@vmware.com>
 <201005051029.42052.dtor@vmware.com>
 <20100505173120.GA1752@infradead.org>
 <201005051035.29831.dtor@vmware.com>
 <20100505173951.GA8388@infradead.org>
 <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 10:47:10AM -0700, Pankaj Thakkar wrote:
> 
> 
> > -----Original Message-----
> > From: Christoph Hellwig [mailto:hch@infradead.org]
> > Sent: Wednesday, May 05, 2010 10:40 AM
> > To: Dmitry Torokhov
> > Cc: Christoph Hellwig; pv-drivers@vmware.com; Pankaj Thakkar;
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> > virtualization@lists.linux-foundation.org
> > Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for
> > vmxnet3
> > 
> > On Wed, May 05, 2010 at 10:35:28AM -0700, Dmitry Torokhov wrote:
> > > Yes, with the exception that the only body of code that will be
> > > accepted by the shell should be GPL-licensed and thus open and
> > available
> > > for examining. This is not different from having a standard kernel
> > > module that is loaded normally and plugs into a certain subsystem.
> > > The difference is that the binary resides not on guest filesystem
> > > but elsewhere.
> > 
> > Forget about the licensing.  Loading binary blobs written to a shim
> > layer is a complete pain in the ass and totally unsupportable, and
> > also uninteresting because of the overhead.
> 
> [PT] Why do you think it is unsupportable? How different is it from any module
> written against a well maintained interface? What overhead are you talking about?
> 
Overhead of interpreting bytecode plugin is written in. Or are you
saying plugin is x86 assembly (32bit or 64bit btw?) and other arches
will have to have in kernel x86 emulator to use the plugin (like some
of them had for vgabios)? 

--
			Gleb.
