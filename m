From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Fri, 30 Oct 2009 10:13:57 -0700
Message-ID: <20091030171357.GA15020@kroah.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091029131125.GA13809@auslistsprd01.us.dell.com>
 <20091029142554.GA16869@kroah.com>
 <20091029174600.GC3612@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE589682@blrx3m08.blr.amer.dell.com>
 <20091030160845.GA4547@lackof.org>
 <20091030171003.GA7523@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dann frazier <dannf@dannf.org>, Narendra_K@Dell.com,
	kay.sievers@vrfy.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com, bhutchings@solarflare.com
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091030171003.GA7523@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2009 at 12:10:03PM -0500, Matt Domsch wrote:
> ethN is fundamentally a nondeterministic namespace, and trying to
> enforce determinism on it is, from all my attempts, impossible.  Hence
> the desire to change the namespace.  But there can be many
> different naming policies one might want (including the
> nondeterministic ethN policy), and for all other types of devices this
> isn't a problem - we can have all the policies we want, in parallel.
> Only for network devices we can't.

So pick one in your installer and stick with it.  Doesn't seem that
complicated to me...

greg k-h
