From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 05/16] i40e: fix long lines
Date: Fri, 10 Jan 2014 18:05:27 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654F044C@FMSMSX113.amr.corp.intel.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344336-1558-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344869.24222.31.camel@joe-AO722>
	 <063D6719AE5E284EB5DD2968C1650D6D457950@AcuExch.aculab.com>
 <1389350138.2537.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43782 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbaAJSFd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:05:33 -0500
In-Reply-To: <1389350138.2537.3.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, January 10, 2014 2:36 AM
> To: David Laight
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; Williams, Mitch A;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com; Brandeburg,
> Jesse
> Subject: Re: [net-next 05/16] i40e: fix long lines
> 
> On Fri, 2014-01-10 at 10:02 +0000, David Laight wrote:
> > > Another way this could be changed is to put the
> > > return value on a separate line like:
> > >
> > > i40e_status
> > > i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 seid, bool
> set,
> > > 				    struct i40e_asq_cmd_details *cmd_details)
> >
> > Personally I prefer that so I can find the definition by grepping
> > for '^function_name' - but it doesn't seem to be done in any linux
> > source files.
> 
> That form is used in a lot of files.
> $ git grep -E "^[a-z_]+\("
> 

So, Joe, I just want to be clear. Is this a NAK, or just an FYI? If it's a serious issue for you (or Dave), we'll fix it right away. Otherwise, I'll just keep it in mind and come back with a janitorial patch once we've got all of the driver functionality sorted.

-Mitch
