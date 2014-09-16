From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Rusty away 18th September -- 11th October
Date: Tue, 16 Sep 2014 19:20:55 +0300
Message-ID: <20140916162055.GB2437@redhat.com>
References: <87oaunht4b.fsf@rustcorp.com.au>
	<20140911114351.GA25736@redhat.com>
	<87tx4dhbks.fsf@rustcorp.com.au>
	<20140914062116.GA23868@redhat.com>
	<87a95zfto5.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87a95zfto5.fsf@rustcorp.com.au>
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

On Wed, Sep 17, 2014 at 01:23:46AM +0930, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > On Fri, Sep 12, 2014 at 10:58:03AM +0930, Rusty Russell wrote:
> >> "Michael S. Tsirkin" <mst@redhat.com> writes:
> >> > On Thu, Sep 11, 2014 at 10:26:52AM +0930, Rusty Russell wrote:
> >> >> Hi all,
> >> >> 
> >> >>         Probably won't read mail.  Linus, I'll have pull requests early
> >> >> next week; if there's anything needed I'm sure Michael Tsirkin can
> >> >> handle it.
> >> >
> >> > Sure.
> >> > Rusty, there's a small chance virtio 1.0 bits will be ready in time.
> >> > I started working on them based on your virtio-pci-new-layout branch.
> >> >
> >> > If ready before the merge window, are you ok with me merging this
> >> > support (without you having the opportunity to review first)?
> >> 
> >> Sorry, absolutely not.  I *really* want to review this in depth; if we
> >> make a mistake, it's going to hurt us significantly.
> >
> > Right but it's only a merge window - we can fix bugs and even disable
> > the new driver afterwards, can't we?
> 
> Yes, but if we get something wrong we have to live with it.  We made
> that mistake with virtio-pci the first time around...
> 
> It isn't enough that the code 'works', it has to match the spec.  And
> that requires careful thought and review.
> 
> >> And until we have the qemu bits ready, it's really hard to tell if we've
> >> got this right.
> >
> > Sure, I meant if qemu bits are ready too, and if things work together.
> > It wouldn't do to merge a driver that isn't ready.
> >
> >
> >>  So I'd rather delay and make sure we're solid.
> >> 
> >> Thanks,
> >> Rusty.
> >
> > Something else we can do, is refactoring that splits driver
> > out to common and legacy bits, and changes APIs.
> > No?
> 
> Yes, for sure.  But there's no hurry to get those into the merge window.
> 
> Cheers,
> Rusty.

Well my point was if we do put them into the merge window,
just adding a new driver will be easy and is often allowed
pretty late in the cycle.

-- 
MST
