From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Thu, 26 Jun 2014 08:14:39 +0200
Message-ID: <20140626061438.GA2889@unicorn.suse.cz>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
 <87d2dwsfh6.fsf@x220.int.ebiederm.org>
 <CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
 <87lhskpizv.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53443 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbaFZGOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 02:14:44 -0400
Content-Disposition: inline
In-Reply-To: <87lhskpizv.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 06:17:08PM -0700, Eric W. Biederman wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
> 
> > On Wed, Jun 25, 2014 at 5:04 PM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> 
> >> The only thing I see that you can gain by this work is getting around
> >> global limits on neighbor table size.  Something that I think is most
> >> unwise.
> >
> > Yes, this is one the benefits.
> 
> I disagree that removing a global DOS prevention check is a benefit.

Network namespaces are often used for e.g. LXC containers. In such case,
it would IMHO make sense if reaching the limits in one container didn't
affect other containers or the host system.

                                                         Michal Kubecek
