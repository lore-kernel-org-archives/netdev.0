From: Joe Perches <joe@perches.com>
Subject: Re: [trivial PATCH] treewide: Add __GFP_NOWARN to k.alloc calls
 with v.alloc fallbacks
Date: Fri, 26 Jul 2013 21:22:39 -0700
Message-ID: <1374898959.3686.10.camel@joe-AO722>
References: <1371669353.2038.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Lars Ellenberg <drbd-dev@lists.linbit.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Chris Mason <chris.mason@fusionio.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	cluster-devel <cluster-devel@redhat.com>
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <1371669353.2038.45.camel@joe-AO722>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 12:15 -0700, Joe Perches wrote:
> Don't emit OOM warnings when k.alloc calls fail when
> there there is a v.alloc immediately afterwards.
> 
> Converted a kmalloc/vmalloc with memset to kzalloc/vzalloc.

Hey Jiri.

What's your schedule for accepting or rejecting
these sorts of patches?

