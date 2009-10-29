From: dann frazier <dannf@dannf.org>
Subject: Re: [PATCH] udev: create empty regular files to represent
 netinterfaces
Date: Thu, 29 Oct 2009 11:50:46 -0600
Message-ID: <20091029175045.GD3612@ldl.fc.hp.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091029131125.GA13809@auslistsprd01.us.dell.com>
 <20091029142554.GA16869@kroah.com>
 <EDA0A4495861324DA2618B4C45DCB3EE589662@blrx3m08.blr.amer.dell.com>
 <20091029165259.GA9692@kroah.com>
 <EDA0A4495861324DA2618B4C45DCB3EE589663@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg@kroah.com, Matt_Domsch@Dell.com, kay.sievers@vrfy.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	bhutchings@solarflare.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE589663@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2009 at 10:52:52PM +0530, Narendra_K@Dell.com wrote:
> 
> >Sure, it's never guaranteed by the kernel that this will 
> >happen, especially as we speed up the boot process by doing 
> >things async.
> 
> >So again, just fix your installer, or write a new udev rule 
> >for your hardware platforms, or both.  But I still fail to see 
> >why multiple names for network devices _in the kernel_ is a 
> >solution for your issue.
> >
> 
> The char device nodes solution does not propose having multiple names
> for the network interfaces _in the kernel_.

Nor does the udev-only implementation I posted which doesn't rely on
new character devices.

-- 
dann frazier

