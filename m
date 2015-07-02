From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] virtio/vhost: cross endian support
Date: Thu, 2 Jul 2015 08:12:37 +0200
Message-ID: <20150702080916-mutt-send-email-mst@redhat.com>
References: <20150701113150-mutt-send-email-mst@redhat.com>
	<CA+55aFwE+vO2xevQ5jpyC0uJ7gASDwMS4=aDb=78RsJNA-wN1Q@mail.gmail.com>
	<CA+55aFxNfhQv2G6ak4b1A7Tb7zn9E7xfq7N+Pak5RW7VPSb=Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxNfhQv2G6ak4b1A7Tb7zn9E7xfq7N+Pak5RW7VPSb=Vw@mail.gmail.com>
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

On Wed, Jul 01, 2015 at 12:03:59PM -0700, Linus Torvalds wrote:
> On Wed, Jul 1, 2015 at 12:02 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Doing a unconditional byte swap is faster and simpler than the crazy
> > conditionals.
> 
> Unconditional endianness not only makes for simpler and faster code,
> it also ends up being easier to debug and add things like type
> annotations for sparse.
> 
>                 Linus

At least this last one is well covered by these patches: this uses
separate sparse types so all accesses are statically verified by sparse
to use the correct accessor.

-- 
MST
