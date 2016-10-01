From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH] net: Use ns_capable_noaudit() when determining net
 sysctl permissions
Date: Sat, 1 Oct 2016 11:59:02 -0700
Message-ID: <20161001185902.GA12313@dtor-ws>
References: <20160930222431.GA30208@dtor-ws>
 <20161001.032504.1254372735513201320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tyhicks@canonical.com, serge.hallyn@ubuntu.com,
        james.l.morris@oracle.com, ebiederm@xmission.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161001.032504.1254372735513201320.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 01, 2016 at 03:25:04AM -0400, David Miller wrote:
> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Date: Fri, 30 Sep 2016 15:24:31 -0700
> 
> > From: Tyler Hicks <tyhicks@canonical.com>
> > 
> > The capability check should not be audited since it is only being used
> > to determine the inode permissions. A failed check does not indicate a
> > violation of security policy but, when an LSM is enabled, a denial audit
> > message was being generated.
> > 
> > The denial audit message caused confusion for some application authors
> > because root-running Go applications always triggered the denial. To
> > prevent this confusion, the capability check in net_ctl_permissions() is
> > switched to the noaudit variant.
> > 
> > BugLink: https://launchpad.net/bugs/1465724
> > 
> > Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
> > Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> > Signed-off-by: James Morris <james.l.morris@oracle.com>
> > [dtor: reapplied after e79c6a4fc923 ("net: make net namespace sysctls
> > belong to container's owner") accidentally reverted the change.]
> > Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> 
> Applied, but please be clear in the future what tree a patch
> is targetting, in this case 'net-next'.
> 
> You can indicate this in the Subject line "[PATCH net-next]".

Sorry, will do next time.

Thanks.

-- 
Dmitry
