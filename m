From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sun, 10 Jun 2012 12:49:34 +0800
Message-ID: <20120610044934.GA10507@localhost>
References: <20120610015832.GA9175@localhost>
	<20120609.190451.182034193302304295.davem@davemloft.net>
	<20120610031634.GA10032@localhost>
	<20120609.212147.1738198233131370927.davem@davemloft.net>
	<20120610044339.GA10436@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120610044339.GA10436@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 10, 2012 at 12:43:39PM +0800, Fengguang Wu wrote:
> On Sat, Jun 09, 2012 at 09:21:47PM -0700, David Miller wrote:
> > From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > Date: Sun, 10 Jun 2012 11:16:34 +0800
> > 
> > > In long run, such build-fix patches can also be auto tested and
> > > reported, somehow in this way. You just create a temporary branch
> > 
> > Sorry, no.
> 
> That's fine. Then how about including some text "fix build errors" or
> "fix build warnings" or paste the original gcc error/warning messages,
> somewhere in the changelog or subject?
> 
> That will also allow me recognize that it's a build fix commit and to
> make it unconditionally report back any build results.

Or better, simply include a 

        Reported-by: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

line in the commit. Then I can reliably detect that it actually tries
to fix some build error/waring reported by me, and verbosely report
back whether the commit actually fix things up.

Thanks,
Fengguang
