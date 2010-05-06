From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 16:19:18 -0400
Message-ID: <20100506201918.GB17922@infradead.org>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com> <20100506081933.GF10044@redhat.com> <20100506180411.GC25364@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gleb Natapov <gleb@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100506180411.GC25364@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 06, 2010 at 11:04:11AM -0700, Pankaj Thakkar wrote:
> Plugin is x86 or x64 machine code. You write the plugin in C and compile it using gcc/ld to get the object file, we map the relevant sections only to the OS space. 

Which is simply not supportable for a cross-platform operating system
like Linux.
