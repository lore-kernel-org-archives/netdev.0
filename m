From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: manual merge of the driver-core tree with the net tree
Date: Thu, 20 May 2010 23:46:22 -0700
Message-ID: <m1tyq1wy4h.fsf@fess.ebiederm.org>
References: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100521162134.6b6326bd.sfr@canb.auug.org.au> (Stephen Rothwell's message of "Fri\, 21 May 2010 16\:21\:34 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi Greg,
>
> Today's linux-next merge of the driver-core tree got a conflict in
> net/core/net-sysfs.c between commits
> 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive Packet Steering")
> and fec5e652e58fa6017b2c9e06466cb2a6538de5b4 ("rfs: Receive Flow
> Steering") from the net tree and commits
> bc28c84244da26bafb0d3bce95ef45212b31c6b8 ("net/sysfs: Fix the bitrot in
> network device kobject namespace support") and
> 83dc0fbf37495691219d019ec16b40d8592d2956 ("net: Expose all network
> devices in a namespaces in sysfs") from the driver-core tree.
>
> I fixed it up (I think - see below) and can carry the fix as necessary.

It looks right, except perhaps the RPS code looks like it will cause a
build failure with sysfs disabled, but that has nothing to do with your
changes.  I don't see any real conflicts here, just two patches passing
very close to each other.

Thanks for the heads up.

Eric
