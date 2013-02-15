From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [STABLE REQUEST] Merge to linux-3.4.y net: Downgrade
 CAP_SYS_MODULE deprecated message from error to warning.
Date: Thu, 14 Feb 2013 16:45:51 -0800
Message-ID: <20130215004551.GA9060@kroah.com>
References: <CAKixpbjutA_84JzM0Zjtw-Pxo8m3KCP9+R_aSJWTPaCqCsVbsw@mail.gmail.com>
 <20130214233735.GA4390@kroah.com>
 <CAKixpbhtD-mhAESjV3HOZRxYqvsWrjH0vTpDgKZuUismUvVa-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	mirq-linux@rere.qmqm.pl, jpirko@redhat.com, therbert@google.com,
	netdev@vger.kernel.org
To: Vinson Lee <vlee@twitter.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKixpbhtD-mhAESjV3HOZRxYqvsWrjH0vTpDgKZuUismUvVa-g@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 14, 2013 at 04:16:18PM -0800, Vinson Lee wrote:
> On Thu, Feb 14, 2013 at 3:37 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Thu, Feb 14, 2013 at 03:29:44PM -0800, Vinson Lee wrote:
> >> Hi.
> >>
> >> I would like to nominate commit
> >> 7cecb523adedcaf8acba5e14d47559d8bc3f40d7 for backport to stable
> >> branches 3.4 and earlier.
> >>
> >> commit 7cecb523adedcaf8acba5e14d47559d8bc3f40d7
> >> Author: Vinson Lee <vlee@twitter.com>
> >> Date:   Wed Jun 27 14:32:07 2012 +0000
> >>
> >>     net: Downgrade CAP_SYS_MODULE deprecated message from error to warning.
> >>
> >>     Make logging level consistent with other deprecation messages in net
> >>     subsystem.
> >>
> >>     Signed-off-by: Vinson Lee <vlee@twitter.com>
> >>     Cc: David Mackey <tdmackey@twitter.com>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > I fail to see how this patch meets the rules described in
> > Documentation/stable_kernel_rules.txt.  What am I missing?
> >
> > thanks,
> >
> > greg k-h
> 
> I am logging different kernel log-level messages to different files
> and monitoring them here. I see this message most often in the errors
> pile. It's arguable that this is not a bug, but it is definitely
> bothering me here. Please consider for backport but I would understand
> if this request was turned down.

As it's not a "bug", and it's something trivial you can fix on your end
if it really annoys you (you should be fixing the root problem here, not
the kernel log message, right?), I'm not going to take it in the -stable
tree.

Unless the network maintainers want to override me, in which case, I'll
be glad to take it then :)

thanks,

greg k-h
