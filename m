From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 27 Aug 2009 20:40:02 +0930
Message-ID: <200908272040.02628.rusty@rustcorp.com.au>
References: <cover.1250693417.git.mst@redhat.com> <200908252140.41295.rusty@rustcorp.com.au> <20090827104517.GB8545@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org,
 kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 mingo@elte.hu,
 linux-mm@kvack.org,
 akpm@linux-foundation.org,
 hpa@zytor.com,
 gregory.haskins@gmail.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090827104517.GB8545@redhat.com>
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Aug 2009 08:15:18 pm Michael S. Tsirkin wrote:
> On Tue, Aug 25, 2009 at 09:40:40PM +0930, Rusty Russell wrote:
> > Also, see other fixes to the lguest launcher since then which might
> > be relevant to this code:
> > 	lguest: get more serious about wmb() in example Launcher code
> 
> Heh, this just gets one step closer to a real wmb.  I just used the
> correct code from linux, so I think nothing needs to be done in vhost.
> Apropos this change in lguest: why is a compiler barrier sufficient? The
> comment says devices are run in separate threads (presumably from
> guest?), if so don't you need to tell CPU that there's a barrier as
> well?

Yep, but x86 only :)  The kernel uses a real insn if XMM/XMM2, but I don't
know if userspace needs that.  I just use compiler barriers.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
