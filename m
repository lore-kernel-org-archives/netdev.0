From: Adam Lee <adam.lee@canonical.com>
Subject: Re: [PATCH 1/3] rtlwifi: make MSI support a module parameter
Date: Tue, 6 May 2014 10:19:15 +0800
Message-ID: <20140506021915.GA3624@adam-laptop>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
 <5367A690.7010305@lwfinger.net>
 <20140505154037.19620ac2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57994 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933711AbaEFCTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 22:19:33 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so7875566pab.28
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 19:19:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140505154037.19620ac2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 05, 2014 at 03:40:37PM -0700, Stephen Hemminger wrote:
> On Mon, 05 May 2014 09:56:16 -0500
> Larry Finger <Larry.Finger@lwfinger.net> wrote:
> 
> > On 05/05/2014 03:33 AM, Adam Lee wrote:
> > > This makes MSI support a module parameter, for debugging and workaround
> > > convenience.
> > >
> > > Signed-off-by: Adam Lee <adam.lee@canonical.com>  
> > 
> > Acked-by: Larry Finger <Larry.Finger@lwfinger.net> (for all 3 patches)
> > 
> > I would have made the default for the MSI option to be true, but that is a 
> > matter of preference, and only experience would show which default leads to the 
> > fewer failures. On my laptop, both rtl8188ee and rtl8723be work either way. I am 
> > now working on a driver for the RTL8192EE that also can use MSI - that has only 
> > been tested with the option on.
> > 
> > Larry
> 
> Standard practice is to assume MSI is available, and let the quirks
> in the PCI subsystem reject the request to enable MSI.
> 
> Also other drivers have a 'disable_msi' module parameter why not follow
> their example.
> 

Because some submodule's MSI causes an regression, and other submodules
of rtlwifi are not fully tested under MSI, we need to disable it by
default(regression has higher priority) and have an 'enable_msi' module
parameter for some certain users.

-- 
Adam Lee
