From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Sun, 1 Nov 2015 19:07:01 -0500
Message-ID: <20151102000701.GD9552@oracle.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
 <20151030231301.GA14974@oracle.com>
 <20151101162407.GA26373@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD1C9@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46549 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbbKBAHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 19:07:01 -0500
Content-Disposition: inline
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFAD1C9@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/01/15 21:03), Nelson, Shannon wrote:
> .. In the meantime, be sure to test what happens over a reset, such as what
> happens when the MTU is changed.  This will make sure that the replay
> of mac and vlan filters happens correctly.  You'll want to test this
> with and without vlans.

I assume you mean .1q (aka linux macvlan) as opposed to access/trunk vlans? 
I will test that tomorrow but I did a quick sanity check on mtu, as well
as turning tso on/off which also restarts the driver (I believe), and
it was "fine", i.e., able to ping offlink hosts. 

--Sowmini
