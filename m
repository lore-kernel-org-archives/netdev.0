From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 1/3] virtio_net: Stop doing DMA from the stack
Date: Thu, 29 Oct 2015 16:43:20 -0700
Message-ID: <CALCETrVEWxHL84EoWr9irOJNnmfav4EqHsT-YDqPcsM92ZYWCg@mail.gmail.com>
References: <cover.1446009834.git.luto@kernel.org>
	<b049d57c66d2fa62e0bafa9cf982de62310f4423.1446009834.git.luto@kernel.org>
	<20151028084249-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390 <linux-s390@vger.kernel.org>, Joerg Roedel <jroedel@suse.de>,
	KVM <kvm@vger.kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>, David Woodhouse <dwmw2@infradead.org>,
	Christoph Hellwig <hch@lst.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20151028084249-mutt-send-email-mst@redhat.com>
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

On Wed, Oct 28, 2015 at 12:07 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> How about this instead? Less code, more robust.
>
> Warning: untested.  If you do like this approach, Tested-by would be
> appreciated.

I like it.

Tested-by: Andy Lutomirski <luto@kernel.org>

--Andy
