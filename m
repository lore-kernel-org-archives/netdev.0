From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: RE: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly
 on some I218 controllers
Date: Wed, 10 Aug 2016 15:00:05 +0000
Message-ID: <630A6B92B7EDEB45A87E20D3D286660153DE9E12@hasmsx109.ger.corp.intel.com>
References: <579F407E.9090602@compulab.co.il>
 <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
 <57A6F7A9.1030401@compulab.co.il>
 <f9d596bd-226b-0faf-bab1-858823f17ee4@intel.com>
 <309B89C4C689E141A5FF6A0C5FB2118B81F70C7D@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Avargil, Raanan" <raanan.avargil@intel.com>,
	Denis Turischev <denis.turischev@compulab.co.il>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B81F70C7D@ORSMSX101.amr.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Denis,
In case this reset help you fix initialization error of I218 you can use it locally on your system. How many system with I218 encountered with initialization error on your side?

Thanks,
Sasha
-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Brown, Aaron F
Sent: Tuesday, August 09, 2016 9:59 PM
To: Avargil, Raanan <raanan.avargil@intel.com>; Denis Turischev <denis.turischev@compulab.co.il>; intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly on some I218 controllers



> -----Original Message-----
> From: Avargil, Raanan
> Sent: Tuesday, August 9, 2016 8:11 AM
> To: Denis Turischev <denis.turischev@compulab.co.il>; intel-wired- 
> lan@lists.osuosl.org; Brown, Aaron F <aaron.f.brown@intel.com>; 
> Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized 
> correctly on some I218 controllers
> 
> 
> 
> On 8/7/2016 11:56, Denis Turischev wrote:
> > Hi Raanan,
> >
> > On 08/04/2016 07:18 PM, Raanan Avargil wrote:
> >> It is hard to determine what is exactly the problem here and what 
> >> causes
> the -3 error, but this is not the place to perform hw reset and retry 
> to init the phy.
> > I agree that may be this is not the correct place for hw reset, can 
> > you advice
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
_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
