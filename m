From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULL] virtio, vhost: new device, fixes, speedups
Date: Fri, 16 Dec 2016 09:32:36 -0800
Message-ID: <CA+55aFwob3KKmHn6G5QxrynXqTu2Es9_RUSdNrJssjHyqoW5NQ@mail.gmail.com>
References: <20161216010507-mutt-send-email-mst@kernel.org>
	<CA+55aFxwG=jj6=2fKjNkHCOnbKr-mNvNucbA=CSdPvb4kzW3FA@mail.gmail.com>
	<20161216184123-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161216184123-mutt-send-email-mst@kernel.org>
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

On Fri, Dec 16, 2016 at 9:09 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Oh, that's because I set orderfile globally rather than
> just for the qemu project which wants it.
> Fixed, sorry about that.

That explains it. I should have remembered, I think this came up once
before with somebody else.

Yeah, for the kernel it makes things much easier (at least for me) to
have everything just the default alphabetical ordering, particularly
because we use directory structure for maintenance areas.

So ordering the diffs by type ends up breaking my mental model for "is
this pull request touching the right files", which is why I reacted.

             Linus
