From: Adam Lee <adam.lee@canonical.com>
Subject: Re: [PATCH 1/3] rtlwifi: make MSI support a module parameter
Date: Wed, 7 May 2014 10:52:30 +0800
Message-ID: <20140507025230.GB3712@adam-laptop>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
 <5367A690.7010305@lwfinger.net>
 <20140505154037.19620ac2@nehalam.linuxnetplumber.net>
 <20140506021915.GA3624@adam-laptop>
 <20140506180836.GF3518@tuxdriver.com>
 <20140507023105.GA3712@adam-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46746 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbaEGCwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 22:52:35 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so434071pab.27
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 19:52:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140507023105.GA3712@adam-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 10:31:05AM +0800, Adam Lee wrote:
> On Tue, May 06, 2014 at 02:08:37PM -0400, John W. Linville wrote:
> > > > Standard practice is to assume MSI is available, and let the quirks
> > > > in the PCI subsystem reject the request to enable MSI.
> > > > 
> > > > Also other drivers have a 'disable_msi' module parameter why not follow
> > > > their example.
> > > > 
> > > 
> > > Because some submodule's MSI causes an regression, and other submodules
> > > of rtlwifi are not fully tested under MSI, we need to disable it by
> > > default(regression has higher priority) and have an 'enable_msi' module
> > > parameter for some certain users.
> > 
> > Couldn't it be called 'disable_msi' and default to 'on'?
> 
> It could be, will send an v2 patchset, thanks.

Sorry, just grep linux/driver, there is no convention of 'disable_msi'
parameter, only 5 drivers uses that, but 15 drivers are using 'msi'...

Please still apply v1, setting 'disable_msi' to 'on' and asking users to
set it to 'off' is a little weird. John, please ask me to send v2 if you
think the 'disable_msi' parameter is better.

Thanks.

-- 
Adam Lee
