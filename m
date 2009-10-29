From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Thu, 29 Oct 2009 17:12:13 +0000
Message-ID: <1256836333.2827.65.camel@achroite>
References: <20091016214024.GA10091@ldl.fc.hp.com>
	 <20091022063619.GB6321@ldl.fc.hp.com>
	 <20091027205551.GA31963@auslistsprd01.us.dell.com>
	 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
	 <20091029131125.GA13809@auslistsprd01.us.dell.com>
	 <20091029142554.GA16869@kroah.com> <1256834975.2827.63.camel@achroite>
	 <20091029165556.GA9846@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091029165556.GA9846@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-10-29 at 09:55 -0700, Greg KH wrote:
> On Thu, Oct 29, 2009 at 04:49:35PM +0000, Ben Hutchings wrote:
> > 3. Name assignment mechanism
> > Disks: kernel suggests a name; udev can assign any number
> > ???Net devices: kernel assigns a single name; udev can override it
> > 
> > 4. Default name assignment policy
> > Disks: names disk by device path (id), label and UUID
> > ???Net devices: assigns arbitrary stable names per (MAC address, subtype)
> > 
> > 5. Naming by users
> > Disks: user can identify by any method without having to choose on a
> > system-wide basis
> > Net devices: user must identify by single name; policy can be overridden
> > on a system-wide basis
> > 
> > I fully understand the technical reasons for differences 3-5, but why
> > should users have to put up with it?
> 
> That is because network devices are not referred to by /dev/ nodes where
> multiple symlinks would solve the naming problem.

Did you even read the last sentence?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

