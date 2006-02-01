From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: 2.6.16-rc1-mm4: ACX=y, ACX_USB=n compile error
Date: Wed, 1 Feb 2006 08:57:04 +0200
Message-ID: <200602010857.04964.vda@ilport.com.ua>
References: <20060130133833.7b7a3f8e@zwerg> <200601311658.09423.vda@ilport.com.ua> <20060131221637.GJ3986@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Gabriel C." <crazy@pimpmylinux.org>, da.crew@gmx.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030556AbWBAG5e@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060131221637.GJ3986@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 February 2006 00:16, Adrian Bunk wrote:
> > > > CONFIG_ACX=y
> > > > # CONFIG_ACX_PCI is not set
> > > > # CONFIG_ACX_USB is not set
> > > > 
> > > > This won't fly. You must select at least one.
> > > > 
> > > > Attached patch will check for this and #error out.
> > > > Andrew, do not apply to -mm, I'll send you bigger update today.
> > > 
> > > Is there any way to move this into a Kconfig file?  That seems nicer
> > > than having #ifdefs in source code to check for a configuration error.
> > 
> > Can't think of any at the moment.
> 
> There are two possible solutions ("offer" means "is user visible"):
> - only offer ACX and always build ACX_PCI/ACX_USB depending on the
>   availability of PCI/USB
> - only offer ACX_PCI and ACX_USB which select ACX
> 
> If you tell me which you prefer I can send a patch.

Second one sounds okay to me.
--
vda
