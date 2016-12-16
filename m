From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PULL] virtio, vhost: new device, fixes, speedups
Date: Fri, 16 Dec 2016 11:12:53 +0100
Message-ID: <81524977-25e7-c13c-7387-3dc86e1924fc@redhat.com>
References: <20161216010507-mutt-send-email-mst@kernel.org>
	<CA+55aFxwG=jj6=2fKjNkHCOnbKr-mNvNucbA=CSdPvb4kzW3FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>, arend.vanspriel@broadcom.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	KVM list <kvm@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+55aFxwG=jj6=2fKjNkHCOnbKr-mNvNucbA=CSdPvb4kzW3FA@mail.gmail.com>
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



On 16/12/2016 03:20, Linus Torvalds wrote:
> On Thu, Dec 15, 2016 at 3:05 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> 
> Pulled, but I wonder...
> 
>>  Documentation/translations/zh_CN/sparse.txt        |   7 +-
>>  arch/arm/plat-samsung/include/plat/gpio-cfg.h      |   2 +-
>>  drivers/crypto/virtio/virtio_crypto_common.h       | 128 +++++
> [...]
> 
> what are you generating these diffstats with? Because they are pretty bogus..
> 
> The end result is correct:
> 
>>  86 files changed, 2106 insertions(+), 280 deletions(-)
> 
> but the file order in the diffstat is completely random, which makes
> it very hard to compare with what I get. It also makes it hard to see
> what you changed, because it's not alphabetical like it should be
> (strictly speaking the git pathname ordering isnt' really
> alphabetical, since the '/' sorts as the NUL character, but close
> enough).
> 
> I can't see the logic to the re-ordering of the lines, so I'm
> intrigued how you even generated it.

Looks like a diff.orderFile that places .h and .txt first, then .c, then
Makefile.  I've seen others propose it.

Paolo
