From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Tue, 16 Dec 2008 21:57:32 +0300
Message-ID: <4947FA1C.2090509@vlnb.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net> <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Evgeniy Polyakov <zbr@ioremap.net>, linux-scsi@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20081215231801.GA27168@infradead.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> If you don't believe that increasing struct page size for a fringe
> feature is a no-go submit the patch to the VM people and wait..

I guessed, it can be no-go, this is why I wrote that this feature isn't 
required for iSCSI-SCST functionality. But, since the implementation is 
*so* simple and doesn't do any layering violation, I have a hope that 
once it disabled by default it will be harmless and, hence, could be 
accepted. Only few people need this feature. Otherwise there will be an 
alternative for them between enable that feature, then recompile, vs 
patch the kernel, enable that feature, then recompile.

When I was developing it my main goal was to do it as simple as 
possible. I believe, I succeeded in it. If it's rejected, it will simply 
live out of tree until me or somebody else finds time to reimplement it 
in an acceptable, although at least 10 times more complicated manner.

Thanks, I'll follow your advise.

Vlad
