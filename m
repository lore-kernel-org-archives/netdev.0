From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 11:41:12 -0200
Message-ID: <20051102134112.GB2609@logos.cnet>
References: <20051102054702.GB11266@alpha.home.local> <OF0C913512.B3EB99A5-ON882570AD.0025FB9D-882570AD.00276427@us.ibm.com> <20051102092959.GA15515@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Yan Zheng <yzcorp@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965202AbVKBTvF@vger.kernel.org>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20051102092959.GA15515@alpha.home.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2005 at 10:29:59AM +0100, Willy Tarreau wrote:
> On Tue, Nov 01, 2005 at 11:10:29PM -0800, David Stevens wrote:
> > Willy Tarreau <willy@w.ods.org> wrote on 11/01/2005 09:47:02 PM:
> > 
> > > Hi,
> > > 
> > > On Tue, Nov 01, 2005 at 06:37:43PM +0800, Yan Zheng wrote:
> > > > You can reproduce this bug by follow codes. This program will cause a
> > > > change to include report even though the first socket's filter mode is
> > > > exclude.
> > > 
> > > I've not clearly understood the nature of the bug, does it also
> > > affect 2.4 ? Marcelo will be releasing 2.4.32 in a few days, so
> > > it would be wise to merge the fix soon.
> > > 
> > > Regards,
> > > Willy
> > > 
> > 
> >         Yes.
> >  
> >         Multicast source filters aren't widely used yet, and that's
> > really the only feature that's affected if an application actually
> > exercises this bug, as far as I can tell. An ordinary filter-less
> > multicast join should still work, and only forwarded multicast
> > traffic making use of filters and doing empty-source filters with
> > the MSFILTER ioctl would be at risk of not getting multicast
> > traffic forwarded to them because the reports generated would not
> > be based on the correct counts.
> >         But having the fix in is better than having it broken, even
> > for that case. :-)
> 
> 
> OK, thanks for the clarification, I understand better now :-)
> 
> Marcelo, David, does this backport seem appropriate for 2.4.32 ? I verified
> that it compiles, nothing more. If it's OK, I've noticed another patch that
> Yan posted today and which might be of interest before a very solid release.

Hi Willy,

Given the fact that it is a bug correction, sure. 
Could you please prepare a nice e-mail with the full description?

Thanks
