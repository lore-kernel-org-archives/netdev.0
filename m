From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 9 May 2011 15:49:07 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018E1CF36A@orsmsx508.amr.corp.intel.com>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
 <20110509154527.28a72365@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61639 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab1EIWtL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 18:49:11 -0400
In-Reply-To: <20110509154527.28a72365@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Monday, May 09, 2011 3:45 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; davem@davemloft.net
> Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
> data size
> 
> On Mon, 09 May 2011 15:26:29 -0700
> Greg Rose <gregory.v.rose@intel.com> wrote:
> 
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -56,6 +56,7 @@
> >  struct rtnl_link {
> >  	rtnl_doit_func		doit;
> >  	rtnl_dumpit_func	dumpit;
> > +	rtnl_calcit_func calcit;
> >  };
> 
> Minor nit, why not line up the columns like the other two?

Haste I suppose.

If this RFC gets the go ahead I'll clean it up.  There's other check patch failures I need to fix anyways but I didn't want to spend a lot of time on something I wasn't sure would fly.

Thanks,

- Greg

