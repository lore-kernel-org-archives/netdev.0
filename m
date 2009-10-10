From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Real networking namespace
Date: Fri, 9 Oct 2009 19:08:20 -0700
Message-ID: <20091009190820.0a0f09c2@nehalam>
References: <20091009083807.16e55b08@nehalam>
	<1255106246.2182.219.camel@moss-pluto.epoch.ncsc.mil>
	<1255106692.2182.224.camel@moss-pluto.epoch.ncsc.mil>
	<200910091812.16046.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200910091812.16046.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Oct 2009 18:12:15 -0400
Paul Moore <paul.moore@hp.com> wrote:

> On Friday 09 October 2009 12:44:52 pm Stephen Smalley wrote:
> > On Fri, 2009-10-09 at 12:37 -0400, Stephen Smalley wrote:
> > > On Fri, 2009-10-09 at 08:38 -0700, Stephen Hemminger wrote:
> > > > The existing networking namespace model is unattractive for what I
> > > > want, has anyone investigated better alternatives?
> > > >
> > > > I would like to be able to allow access to a network interface and
> > > > associated objects (routing tables etc), to be controlled by Mandatory
> > > > Access Control API's. I.e grant access to eth0 and to only certain
> > > > processes.  Some the issues with the existing models are:
> > > >   * eth0 and associated objects don't really exist in filesystem so
> > > >     not subject to LSM style control (SeLinux/SMACK/TOMOYO)
> 
> As Stephen points out, SELinux does have the ability to assign security labels 
> to network interfaces, check out the 'semanage' command.  A while back I wrote 
> up something about the SELinux network "ingress/egress" access controls:
> 
>  * http://paulmoore.livejournal.com/2128.html

I was hoping to be able to not have inaccessible interfaces visible,
is it possible to not have interfaces show up in commands like:
  ip link show
or sysfs?


-- 
