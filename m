From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 09:46:21 +0300
Message-ID: <20130516064620.GB26995@redhat.com>
References: <8761yk254u.fsf@rustcorp.com.au>
	<1368657450.6899.29.camel@haakon3.risingtidesystems.com>
	<871u9724vp.fsf@rustcorp.com.au>
	<20130515.201055.1401062016041347476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, rdunlap@infradead.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130515.201055.1401062016041347476.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, May 15, 2013 at 08:10:55PM -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 16 May 2013 09:05:38 +0930
> 
> > memcpy_fromiovec() has nothing to do with networking: that was just the
> > first user.  Note that crypto/algif_skcipher.c also uses it.  The
> > obvious answer is to move it into lib/.
> 
> +1

Rusty sent a patch that does this:
http://patchwork.ozlabs.org/patch/244207/

David, looks like you weren't CC'd.
If you agree could you please Ack that patch and then I can merge it
through the vhost tree?
Or if you prefer merge it directly and I'll sort out the dependencies...

Thanks,

-- 
MST
