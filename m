From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 09:15:16 -0400
Message-ID: <1243602916.3966.11.camel@dogo.mojatatu.com>
References: <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<20090529074812.GA5483@ff.dom.local>
	<20090529080330.GB5483@ff.dom.local>
	<20090529102232.GA6279@ff.dom.local>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529102232.GA6279-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for the CC Jarek.

On Fri, 2009-05-29 at 10:22 +0000, Jarek Poplawski wrote:

> > > I didn't verify this too much, so I might be wrong, but it looks like
> > > cls_cgroup_classify() does things a bit different than others (doesn't
> > > check the 'head' etc. for NULL), so maybe you should consider fixing
> > > it instead? (Btw., the tc classifier maintainer added to Cc).
> > 
> > OOPS! Others mostly don't check this either, so my suggestion was wrong.
> 
> Hmm... Or maybe I wasn't so wrong; it seems classifiers which
> don't assign the head during init do this check for NULL later.

It is good practise to initialize things in init() and use attributes
in change() to set them. 
I will read the thread and check out the code path then respond
more intelligently.

cheers,
jamal
