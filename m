From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] virtio-net: remove useless disable on freeze
Date: Wed, 30 May 2012 19:41:47 +0930
Message-ID: <87r4u2dllo.fsf@rustcorp.com.au>
References: <20120404091954.GA3776@redhat.com>
	<20120528125325.GA22576@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120528125325.GA22576@redhat.com>
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

On Mon, 28 May 2012 15:53:25 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Wed, Apr 04, 2012 at 12:19:54PM +0300, Michael S. Tsirkin wrote:
> > disable_cb is just an optimization: it
> > can not guarantee that there are no callbacks.
> > 
> > I didn't yet figure out whether a callback
> > in freeze will trigger a bug, but disable_cb
> > won't address it in any case. So let's remove
> > the useless calls as a first step.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Looks like this isn't in the 3.5 pull request -
> just lost in the shuffle?
> disable_cb is advisory so can't be relied upon.

I always (try to?) reply as I accept patches.

This one did slip by, but it's harmless so no need to push AFAICT.

Applied.

Thanks!
Rusty.
