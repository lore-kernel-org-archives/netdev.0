From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Wed, 15 May 2013 20:10:55 -0700 (PDT)
Message-ID: <20130515.201055.1401062016041347476.davem@davemloft.net>
References: <8761yk254u.fsf@rustcorp.com.au>
	<1368657450.6899.29.camel@haakon3.risingtidesystems.com>
	<871u9724vp.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rdunlap@infradead.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, linux-next@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <871u9724vp.fsf@rustcorp.com.au>
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

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 16 May 2013 09:05:38 +0930

> memcpy_fromiovec() has nothing to do with networking: that was just the
> first user.  Note that crypto/algif_skcipher.c also uses it.  The
> obvious answer is to move it into lib/.

+1
