From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Wed, 15 May 2013 14:47:53 +0930
Message-ID: <8761yk254u.fsf@rustcorp.com.au>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au> <1368579583-13097-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Bellinger <nab@linux-iscsi.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, Asias He <asias@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Randy Dunlap <rdunlap@infradead.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	<netdev@vger.kernel.org>
To: Asias He <asias@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1368579583-13097-1-git-send-email-asias@redhat.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Asias He <asias@redhat.com> writes:
> scsi.c includes vhost.c which uses memcpy_fromiovec.
>
> This patch fixes this build failure.
>
>    From Randy Dunlap:
>    '''
>    on x86_64:
>
>    ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
>
>    It needs to depend on NET since net/core/ provides that function.
>    '''

Proper fix please.

Though I can't see why you thought this was a good idea.  Nonetheless, I
shan't highlight why: I have far too much respect for your intellects
and abilities.

No, don't thank me!
Rusty.
