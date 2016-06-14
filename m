From: Andrey Vagin <avagin@virtuozzo.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 14:21:28 -0700
Message-ID: <20160614205741.GB20722@outlook.office365.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <20160614171528.GA14276@outlook.office365.com>
 <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: "Eggert, Lars" <lars@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0111.outbound.protection.outlook.com ([157.56.112.111]:10228
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750771AbcFNVg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:36:56 -0400
Content-Disposition: inline
In-Reply-To: <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 07:37:12PM +0000, Eggert, Lars wrote:
> Hi,
> 
> On 2016-06-14, at 19:15, Andrey Vagin <avagin@virtuozzo.com> wrote:
> > Recently we found that we have to restore more parameters for tcp
> > sockets.
> > https://patchwork.kernel.org/patch/9144995/
> 
> thanks for the pointer.
> 
> > As for your problem, criu saves and restores mss_clamp. Could you check
> > that it works for your case?
> 
> I do this already, but clamping doesn't help here, since it only limits the MSS (but does not increase it from the minimum.)

Yes, you are right.

On my host, I see that dst is set in tcp_v4_connect() -> sk_setup_caps()

> 
> Lars
