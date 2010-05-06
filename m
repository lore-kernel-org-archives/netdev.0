From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 11:04:11 -0700
Message-ID: <20100506180411.GC25364@vmware.com>
References: <20100504230225.GP8323@vmware.com>
	<201005051029.42052.dtor@vmware.com>
	<20100505173120.GA1752@infradead.org>
	<201005051035.29831.dtor@vmware.com>
	<20100505173951.GA8388@infradead.org>
	<F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
	<20100506081933.GF10044@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@vmware.com>,
        "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
To: Gleb Natapov <gleb@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20100506081933.GF10044@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, May 06, 2010 at 01:19:33AM -0700, Gleb Natapov wrote:
> Overhead of interpreting bytecode plugin is written in. Or are you
> saying plugin is x86 assembly (32bit or 64bit btw?) and other arches
> will have to have in kernel x86 emulator to use the plugin (like some
> of them had for vgabios)? 
> 

Plugin is x86 or x64 machine code. You write the plugin in C and compile it using gcc/ld to get the object file, we map the relevant sections only to the OS space. 

NPA is a way of enabling passthrough of SR-IOV NICs with live migration support on ESX Hypervisor which runs only on x86/x64 hardware. It only supports x86/x64 guest OS. So we don't have to worry about other architectures. If NPA approach needs to be extended and adopted by other hypervisors then we have to take care of that. Today we have two plugins images per VF (one for 32-bit, one for 64-bit).
