From: Neil Horman <nhorman@redhat.com>
Subject: Re: [Patch] net: fix build break when CONFIG_NET_CLS_ACT is not set
Date: Tue, 29 Mar 2005 16:17:41 -0500
Message-ID: <20050329211741.GL22447@hmsendeavour.rdu.redhat.com>
References: <20050329202506.GI22447@hmsendeavour.rdu.redhat.com> <1112130720.1076.112.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112130720.1076.112.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 04:12:01PM -0500, jamal wrote:
> 
> This is being discussed on netdev at the moment. Thomas Graf is working
> on a patch.
> Thanks for the effort though.
> 
> cheers,
> jamal
> 
No worries.  What exactly is the point of contention on netdev? (I'm not
currently following that list).  My patch seems to follow the common practice
for CONFIG_NET_CLS_ACT, in that all references to the action member of the
appropriate struct are themselves ifdef-ed.
Regards,
Neil

> On Tue, 2005-03-29 at 15:25, Neil Horman wrote:
> > Patch to fix build break that occurs when CONFIG_NET_CLS_ACT is not set.
> > 
> > Signed-off-by: Neil Horman <nhorman@redhat.com>
> > 
> >  cls_fw.c      |    3 ++-
> >  cls_route.c   |    3 ++-
> >  cls_tcindex.c |    3 ++-
> >  cls_u32.c     |    2 ++
> >  4 files changed, 8 insertions(+), 3 deletions(-)
> > 
> 
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
