From: Paul Furness <paul.furness@vil.ite.mee.com>
Subject: RE: amd or autofos?
Date: 17 Apr 2002 12:23:50 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1019042630.5769.14.camel@x2.vil.ite.mee.com>
References: <20020416220945.55540.qmail@web12806.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Kelty <jamesk@everbase.net>, linux-net@vger.kernel.org,
	linux-admin@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Christopher Slater <olyar@yahoo.com>
In-Reply-To: <20020416220945.55540.qmail@web12806.mail.yahoo.com>
List-Id: netdev.vger.kernel.org

Thanks, guys, but I already looked at hard NFS mounts and there are
three problems:

1. There are a fair number of machines (over 40) and things change from
time to time because we are an R&D place. Just the time taken to
manually edit the fstabs on all the machines and restart nfs make it
worth looking at alternatives. Also, there's the fact that I need to
interrupt the service for people using that machine when a change is
needed.

2. I want to try and minimise network traffic. I read somewhere (a while
ago, admittedly) that for as long as an nfs mount is mounted, there is
traffic being generated. Since we are researching into various
multimedia things, the network gets fairly regularly hammered by big
file transfers. Anything to reduce traffic is therefore a bonus

3. Stale mounts when things change or crash - the changes happen every
so often, and some crashes happen quite frequently.

I think there is a problem with the versions being too old - that's why
I want to get everything up to RedHat 7.2 (7.3 if it comes out in the
next couple of weeks) as I know for a fact there are some RPC issues
with the older setups.


Thanks for your thoughts.

BUNgle

On Tue, 2002-04-16 at 23:09, Christopher Slater wrote:
> However, by hard mounting the NFS mount you will get stale mounts if
> the server goes down.  
> 
> I've had good luck with AMD, but I think you're right that autofs
> seemed easier to configure.  
> 
> I would guess that you should be able to fix the problem you're
> currently seeing using *either* package.  Could be unrelated to the
> package, or a bug in the older version that might be installed.
> 
> Chris
> 
> --- James Kelty <jamesk@everbase.net> wrote:
> > If you just want to mount the NFS shares at boot and keep them there,
> > you
> > can
> > just edit the /etc/fstab file to reflect that.
> > 
> > -James
> > 


