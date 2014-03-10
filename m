From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: RE: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked()
 declaration
Date: Mon, 10 Mar 2014 20:32:19 +0000
Message-ID: <61CC2BC414934749BD9F5BF3D5D940444FFA1D3B@ORSMSX106.amr.corp.intel.com>
References: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
 <20140310.162820.532220881575176361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: David Miller <davem@davemloft.net>,
	"sakiwit@gmail.com" <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57934 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754054AbaCJUcW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:32:22 -0400
In-Reply-To: <20140310.162820.532220881575176361.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, March 10, 2014 13:28
> To: sakiwit@gmail.com
> Cc: Brown, Aaron F; netdev@vger.kernel.org; Skidmore, Donald C; Kirsher,
> Jeffrey T
> Subject: Re: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked()
> declaration
> 
> From: Jean Sacren <sakiwit@gmail.com>
> Date: Sun,  9 Mar 2014 19:19:02 -0600
> 
> > The commit c97506ab0e22 ("ixgbe: Add check for FW veto bit")
> > introduced the new function ixgbe_check_reset_blocked() with a minor
> > issue in declaration. Fix the declaration by changing the type
> > specifier to bool as the definition returns a boolean value.
> > Additionally all ixgbe_check_reset_blocked() callers are expected to
> > return a boolean value.
> >
> > Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> > Cc: Don Skidmore <donald.c.skidmore@intel.com>
> 
> I assume Jeff will pick this up into his Intel tree.
[Kirsher, Jeffrey T] 

Yes, I will pick it up.  Sorry for the delayed response.
