From: dann frazier <dannf@dannf.org>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Fri, 30 Oct 2009 10:08:45 -0600
Message-ID: <20091030160845.GA4547@lackof.org>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com> <20091029174600.GC3612@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589682@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg@kroah.com, Matt_Domsch@Dell.com, kay.sievers@vrfy.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	bhutchings@solarflare.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE589682@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2009 at 08:43:44PM +0530, Narendra_K@Dell.com wrote:
>  
> >> This way the kernel has only one name, and so does userspace, and 
> >> everyone is happy.
> >
> >There are two issues, which really seem distinct to me.
> >
> >Users expect eth0 to map to first-onboard-nic. That's an 
> >installer issue (since the BIOS can already export this info) 
> >and I agree that if we want to "fix" that, we should fix it there.
> >
> 
> I agree that installers have to be fixed in the sense that they can be
> told to find the right interface. But, they expect determinism and
> depend on "eth0 to map to first-onboard-nic". Installer is one of the
> applications that is affected by this and needs user intervention, if it
> is not told about the right interface. I discussed installer as it is so
> much part of a user experience.

Right, but couldn't the installer do the work of scanning the SMBIOS
to figure out which nics are onboard, and reorder the 'eth*' names
such that these are first? This state could then be written out as
udev rules so that they persist across reboots.

> But the real issue is "eth0 does not map to first-onboard-nic" always
> and applications expecting this would break in data center environments.
> Both the solutions proposed provide a way to overcome it without
> introducing state.
> 
> With regards,
> Narendra K
> 

-- 
dann frazier

