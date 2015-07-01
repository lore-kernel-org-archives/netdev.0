From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULL] virtio/vhost: cross endian support
Date: Wed, 1 Jul 2015 12:02:50 -0700
Message-ID: <CA+55aFwE+vO2xevQ5jpyC0uJ7gASDwMS4=aDb=78RsJNA-wN1Q@mail.gmail.com>
References: <20150701113150-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150701113150-mutt-send-email-mst@redhat.com>
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

On Wed, Jul 1, 2015 at 2:31 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> virtio/vhost: cross endian support

Ugh. Does this really have to be dynamic?

Can't virtio do the sane thing, and just use a _fixed_ endianness?

Doing a unconditional byte swap is faster and simpler than the crazy
conditionals. That's true regardless of endianness, but gets to be
even more so if the fixed endianness is little-endian, since BE is
not-so-slowly fading from the world.

               Linus
