From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH v2 3/3] net: make net namespace sysctls belong to
 container's owner
Date: Fri, 30 Sep 2016 15:26:18 -0700
Message-ID: <20160930222618.GB30208@dtor-ws>
References: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
 <1470864962-25056-4-git-send-email-dmitry.torokhov@gmail.com>
 <CAKdAkRRsVaAupFx+DpjX8VSHS9_ws2WVA47eQoCU-DT1w0JK5w@mail.gmail.com>
 <20160930.012127.347186046201932283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160930.012127.347186046201932283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2016 at 01:21:27AM -0400, David Miller wrote:
> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Date: Thu, 29 Sep 2016 08:46:05 -0700
> 
> > Hi David,
> > 
> > On Wed, Aug 10, 2016 at 2:36 PM, Dmitry Torokhov
> > <dmitry.torokhov@gmail.com> wrote:
> >> If net namespace is attached to a user namespace let's make container's
> >> root owner of sysctls affecting said network namespace instead of global
> >> root.
> >>
> >> This also allows us to clean up net_ctl_permissions() because we do not
> >> need to fudge permissions anymore for the container's owner since it now
> >> owns the objects in question.
> >>
> >> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> >> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> > 
> > I was looking at linux-next today, and I noticed that, when you merged
> > my patch, you basically reverted the following commit:
> > 
> > commit d6e0d306449bcb5fa3c80e7a3edf11d45abf9ae9
> > Author: Tyler Hicks <tyhicks@canonical.com>
> > Date:   Thu Jun 2 23:43:22 2016 -0500
> > 
> >     net: Use ns_capable_noaudit() when determining net sysctl permissions
> 
> Please send me a fixup patch for this, sorry.

Just did, look for <20160930222431.GA30208@dtor-ws>

Thanks.

-- 
Dmitry
