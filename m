From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Mon, 2 Nov 2015 17:26:01 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFAD398@fmsmsx115.amr.corp.intel.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
 <20151030231301.GA14974@oracle.com> <20151101162407.GA26373@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD1C9@fmsmsx115.amr.corp.intel.com>
 <20151102000701.GD9552@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26166 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbbKBR0J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:26:09 -0500
In-Reply-To: <20151102000701.GD9552@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Sunday, November 01, 2015 4:07 PM
> 
> On (11/01/15 21:03), Nelson, Shannon wrote:
> > .. In the meantime, be sure to test what happens over a reset, such as
> what
> > happens when the MTU is changed.  This will make sure that the replay
> > of mac and vlan filters happens correctly.  You'll want to test this
> > with and without vlans.
> 
> I assume you mean .1q (aka linux macvlan) as opposed to access/trunk
> vlans?

Yes, this is what I had in mind.

> I will test that tomorrow but I did a quick sanity check on mtu, as well
> as turning tso on/off which also restarts the driver (I believe), and
> it was "fine", i.e., able to ping offlink hosts.
> 
> --Sowmini

Great, thanks.

sln
