From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Mon, 2 Jul 2012 11:39:14 +0200
Message-ID: <20120702093913.GA9045@redhat.com>
References: <1340786187.1911.24.camel@x61.thuisdomein>
 <1341062406.1911.76.camel@x61.thuisdomein>
 <20120702090602.GA8286@redhat.com>
 <1341221563.1911.141.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1341221563.1911.141.camel-uMdlDhfIn7prKue/0VVhAg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2012 at 11:32:43AM +0200, Paul Bolle wrote:
> On Mon, 2012-07-02 at 11:06 +0200, Stanislaw Gruszka wrote:
> > On Sat, Jun 30, 2012 at 03:20:06PM +0200, Paul Bolle wrote:
> > For some reason we are not able to authenticate, what itself is a
> > problem. Maybe this is wrong key offset problem and that will
> > be fixed by Emmanuel patch.
> 
> Which I can only try if we fix the small problem you mentioned in your
> comment on Emmanuel's patch (reference
> <20120702082653.GA2479-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, not yet archived on lkml.org), can't
> I?
Oh, you were not CCed, and lkml too, v2 patch is here:
http://marc.info/?l=linux-wireless&m=134121823510017&w=2

> > Regarding "Queue 2 stuck", there is another fix in iwlwifi that
> > did not make to iwlegacy, which perhaps could help. If not here
> > then maybe on suspend.  
> > 
> > commit 342bbf3fee2fa9a18147e74b2e3c4229a4564912
> > Author: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Date:   Sun Mar 4 08:50:46 2012 -0800
> > 
> >     iwlwifi: always monitor for stuck queues
> > 
> > I'm attaching iwlegacy version of it.
> 
> Thanks, I'll try it. The explanation of the iwlwifi commit makes a lot
> of sense: it seems to match the events found in the logs of this laptop.
> That's encouraging. Should I report whether the iwlegacy version works
> or not?
Actually I'll post it anyway. But if this patch and Emmanuel's will not 
fix the problem you should report it. 
   
> > > 2) It's always "Queue 2" that's stuck. What does that queue do?
> > 
> > It's TX queue, probably one used for default traffic i.e. for Best
> > Effort category (others are Video, Voice and Background).
> 
> I see.
> 
> Any thoughts on my patch (ie, the patch that is actually the subject of
> this thread?
It was applied to wireless-testing.

Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
