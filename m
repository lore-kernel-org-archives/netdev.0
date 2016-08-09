From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly
 on some I218 controllers
Date: Tue, 9 Aug 2016 18:59:04 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F70C7D@ORSMSX101.amr.corp.intel.com>
References: <579F407E.9090602@compulab.co.il>
 <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
 <57A6F7A9.1030401@compulab.co.il>
 <f9d596bd-226b-0faf-bab1-858823f17ee4@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Avargil, Raanan" <raanan.avargil@intel.com>,
	Denis Turischev <denis.turischev@compulab.co.il>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64705 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932321AbcHITAb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:00:31 -0400
In-Reply-To: <f9d596bd-226b-0faf-bab1-858823f17ee4@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Avargil, Raanan
> Sent: Tuesday, August 9, 2016 8:11 AM
> To: Denis Turischev <denis.turischev@compulab.co.il>; intel-wired-
> lan@lists.osuosl.org; Brown, Aaron F <aaron.f.brown@intel.com>; Kirsher,
> Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly on
> some I218 controllers
> 
> 
> 
> On 8/7/2016 11:56, Denis Turischev wrote:
> > Hi Raanan,
> >
> > On 08/04/2016 07:18 PM, Raanan Avargil wrote:
> >> It is hard to determine what is exactly the problem here and what causes
> the -3 error, but this is not the place to perform hw reset and retry to init the
> phy.
> > I agree that may be this is not the correct place for hw reset, can you advice
> about another solution?
> >
> > It works, not only for me, for example it helps here:
> > http://www.linux.org.ru/forum/linux-hardware/10268216
> >
> > Another fact that Windows drivers work fine with the same hw.
> >
> > Denis
> >
> 
> Hi Denis,
> 
> More suitable place to retry init the device would be in probe function.
> However, we haven't seen initialization issues like this on i218.
> 
> Adding Aaron.
> 
> @Aaron - have you seen initialization errors on i218 devices?

I have not.  But I don't have many systems with i218 so all that means is my systems do not exhibit the problem.

> 
> Raanan
