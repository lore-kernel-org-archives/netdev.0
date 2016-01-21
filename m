From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: virtio pull for 4.5 (was Re: [PULL] virtio: barrier rework+fixes)
Date: Thu, 21 Jan 2016 12:23:07 +0200
Message-ID: <20160121121544-mutt-send-email-mst@redhat.com>
References: <20160113182855-mutt-send-email-mst@redhat.com>
	<20160118152028-mutt-send-email-mst@redhat.com>
	<CA+55aFyh_1Lpp4U2wsFJQu_4PmSBD=36YeAhQN94L4GUhQrb2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tony.luck@intel.com, Rafael Aquini <aquini@redhat.com>,
	KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Boqun Feng <boqun.feng@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Bjorn Andersson <bjorn.andersson@sonymobile.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyh_1Lpp4U2wsFJQu_4PmSBD=36YeAhQN94L4GUhQrb2Q@mail.gmail.com>
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

On Mon, Jan 18, 2016 at 05:01:26PM -0800, Linus Torvalds wrote:
> On Mon, Jan 18, 2016 at 5:21 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > Hi Linus,
> > Just making sure nothing's wrong with this pull request.
> > If there's an issue, pls let me know!
> 
> It was just pulled because I wasn't 100% sure I wanted the extra
> indirection. Oh well, pulled now.
> 
> One question:
> 
>  - the arch/sh/ part of the pacth looks dubious. Why does it do that
> 
>      #define smp_store_mb(var, value) __smp_store_mb(var, value)
> 
>    despite the commit log saying it's done by asm-generic?
> 
> I haven't pushed out yet, my allmodconfig sanity-check build is still going..
> 
>                       Linus

Oh that's because that's what the existing code did, so
the original version of the patch left the bug in place.
I wanted to include the fix and I wrote this in the
commit message, but I forgot to include it in the code :(

Thankfully this just means that the commit log is wrong,
the code is just unchanged from 4.4, and I'll
include a fix in my tree shortly.

-- 
MST
