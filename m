From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/3] r8169:fix kernel log spam when set or get
 hardware wol setting.
Date: Fri, 29 Jul 2016 00:13:50 +0200
Message-ID: <20160728221350.GA22625@electric-eye.fr.zoreil.com>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
 <1469637668-8751-2-git-send-email-hau@realtek.com>
 <20160727221001.GA3338@electric-eye.fr.zoreil.com>
 <80377ECBC5453840BA8C7155328B53770143B749@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hau <hau@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46036 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbcG1WN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 18:13:58 -0400
Content-Disposition: inline
In-Reply-To: <80377ECBC5453840BA8C7155328B53770143B749@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hau <hau@realtek.com> :
[...]
> > Either the driver resumes the device so that it can perform requested
> > operation or it signals .set_wol failure when the device is suspended.
> > 
> > If the driver does something else, "spam removal" translates to "silent
> > failure".
> 
> Because "tp->saved_wolopts" will be used to set hardware wol capability in
> rtl8169_runtime_resume().  So I prefer to keep "wol->wolopts" to
> " tp->saved_wolopts " in runtime suspend state and set this to this
> "wol->wolopts" to hardware in in rtl8169_runtime_resume(). 

It would be fine if it could be proven that rtl8169_runtime_resume() will
always be run before software state is lost.

-- 
Ueimor
