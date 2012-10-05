From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Fri, 05 Oct 2012 09:47:01 +0200
Message-ID: <506E9075.6000104@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
	<87vces2gxq.fsf@rustcorp.com.au> <87mx033u74.fsf@codemonkey.ws>
	<87391u3o67.fsf@rustcorp.com.au> <87wqz6kgg4.fsf@codemonkey.ws>
	<87lifm1y1n.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>,
	Anthony Liguori <anthony@codemonkey.ws>, avi@redhat.com,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87lifm1y1n.fsf@rustcorp.com.au>
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

Il 04/10/2012 09:44, Rusty Russell ha scritto:
> -In particular, no implementation should use the descriptor
> -boundaries to determine the size of any header in a request.[footnote:
> -The current qemu device implementations mistakenly insist that
> -the first descriptor cover the header in these cases exactly, so
> -a cautious driver should arrange it so.
> +[footnote:
> +It was previously asserted that framing should be independent of
> +message contents, yet invariably drivers layed out messages in
> +reliable ways and devices assumed it. In addition, the
> +specifications for virtio_blk and virtio_scsi require intuiting
> +field lengths from frame boundaries.
>  ]

Not true for virtio_scsi...

Paolo
