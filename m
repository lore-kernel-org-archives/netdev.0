From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/3] rtlwifi: make MSI support a module parameter
Date: Tue, 6 May 2014 14:08:37 -0400
Message-ID: <20140506180836.GF3518@tuxdriver.com>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
 <5367A690.7010305@lwfinger.net>
 <20140505154037.19620ac2@nehalam.linuxnetplumber.net>
 <20140506021915.GA3624@adam-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140506021915.GA3624@adam-laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 10:19:15AM +0800, Adam Lee wrote:
> On Mon, May 05, 2014 at 03:40:37PM -0700, Stephen Hemminger wrote:
> > On Mon, 05 May 2014 09:56:16 -0500
> > Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
> > 
> > > On 05/05/2014 03:33 AM, Adam Lee wrote:
> > > > This makes MSI support a module parameter, for debugging and workaround
> > > > convenience.
> > > >
> > > > Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>  
> > > 
> > > Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (for all 3 patches)
> > > 
> > > I would have made the default for the MSI option to be true, but that is a 
> > > matter of preference, and only experience would show which default leads to the 
> > > fewer failures. On my laptop, both rtl8188ee and rtl8723be work either way. I am 
> > > now working on a driver for the RTL8192EE that also can use MSI - that has only 
> > > been tested with the option on.
> > > 
> > > Larry
> > 
> > Standard practice is to assume MSI is available, and let the quirks
> > in the PCI subsystem reject the request to enable MSI.
> > 
> > Also other drivers have a 'disable_msi' module parameter why not follow
> > their example.
> > 
> 
> Because some submodule's MSI causes an regression, and other submodules
> of rtlwifi are not fully tested under MSI, we need to disable it by
> default(regression has higher priority) and have an 'enable_msi' module
> parameter for some certain users.

Couldn't it be called 'disable_msi' and default to 'on'?

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
