From: Christopher Slater <olyar@yahoo.com>
Subject: RE: amd or autofos?
Date: Tue, 16 Apr 2002 15:09:45 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <a9i7fc$ark$2@main.gmane.org>
References: <MDEDIKPCLCIKDGEMDJGMKEMLCIAA.jamesk@everbase.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: James Kelty <jamesk@everbase.net>, linux-net@vger.kernel.org,
	linux-admin@vger.kernel.org
In-Reply-To: <MDEDIKPCLCIKDGEMDJGMKEMLCIAA.jamesk@everbase.net>
List-Id: netdev.vger.kernel.org

However, by hard mounting the NFS mount you will get stale mounts if
the server goes down.  

I've had good luck with AMD, but I think you're right that autofs
seemed easier to configure.  

I would guess that you should be able to fix the problem you're
currently seeing using *either* package.  Could be unrelated to the
package, or a bug in the older version that might be installed.

Chris

--- James Kelty <jamesk@everbase.net> wrote:
> If you just want to mount the NFS shares at boot and keep them there,
> you
> can
> just edit the /etc/fstab file to reflect that.
> 
> -James
> 
> -----Original Message-----
> From: linux-admin-owner@vger.kernel.org
> [mailto:linux-admin-owner@vger.kernel.org]On Behalf Of Paul Furness
> Sent: Tuesday, April 16, 2002 5:59 AM
> To: linux-net@vger.kernel.org; linux-admin@vger.kernel.org
> Subject: amd or autofos?
> 
> 
> Hi, all.
> 
> Is there someone around with lots of experience of auto mounting nfs
> shares on RedHat?
> 
> Here's the setup:
> I have just taken over running the network and servers for this nice
> company, and we currently have a number of servers (all running
> RedHat
> 6.2) that variously run NIS, apache, various databases, and lots of
> disk
> space. The disks are shared using nfs shared, and then mounted using
> AMD
> on whichever machine the user logs in to. This includes not only
> shared
> volumes of data, but also the home directories of the users.
> 
> There is an ongoing problem where AMD on a random machine dies at a
> random time, and has to be restarted so people can access files
> again.
> 
> It is my intention to upgrade all the servers to RH7.2 (I could
> update
> the individual packages and the build a kernel, but a full upgrade
> seems
> a whole lot simpler to manage!) and I also have the chance to update
> how
> some of it works.
> 
> So given an unrestricted choice between ams and autofs, which would
> you
> go for? Is autofs more stable than amd? It certainly looks to be
> slightly better documented and slightly easier to configure.
> 
> Any thoughts would be appreciated.
> 
> Thanks.
> 
> BUNgle
> 
> "One of these days I'll figure how the damn thing works..."
> 
> -
> To unsubscribe from this list: send the line "unsubscribe
> linux-admin" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -
> To unsubscribe from this list: send the line "unsubscribe
> linux-admin" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


__________________________________________________
Do You Yahoo!?
Yahoo! Tax Center - online filing with TurboTax
http://taxes.yahoo.com/
