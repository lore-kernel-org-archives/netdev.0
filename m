From: Ben Greear <greearb@candelatech.com>
Subject: Re: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2
 NIC?
Date: Wed, 18 Jan 2012 14:40:47 -0800
Message-ID: <4F174A6F.8050002@candelatech.com>
References: <1326886258.19261.25.camel@probook> <20120118091351.000052fc@unknown> <m3d3ag7ki8.fsf@ursa.amorsen.dk> <9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38287 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab2ARWlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 17:41:10 -0500
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2012 02:21 PM, Fujinaka, Todd wrote:
>
> -----Original Message-----
> From: Benny Amorsen [mailto:benny+usenet@amorsen.dk]
> Sent: Wednesday, January 18, 2012 1:45 PM
> To: Brandeburg, Jesse
> Cc: Jesper Dangaard Brouer; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: Re: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2 NIC?
>
> Jesse Brandeburg<jesse.brandeburg@intel.com>  writes:
>
>> For X520 adapters, the documentation[1] states that which SFP+
>> adapters are/are not supported.  Direct attach cables are also
>> supported.
>>
>> [1]
>> http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm
>
> I can't believe that locked optics have now arrived on commodity hardware. I have been trying to migrate to all-Intel networking at work; that effort is certainly on hold now.
>
>
> That's up to you. There's "locked" and there's "locked". I'm surprised
> that Benny and Jesper haven't looked at the driver to see where the
> messages come from.

As a datapoint:  We had a customer trying to use a non-supported
SFP+ module in an 82599 NIC, and they hacked the driver to over-rule
the exclusion.  It sort of worked for them, but never well, and never
at any decent throughput.

Now, I have no idea if their SFP+ was decent or not, but at least in
some cases, just over-riding the driver doesn't fix things.

It does seem like Intel could offer a module option to easily over-ride the
SFP+ exclusion for folks that wanted to test new SFP+ modules for them,
however.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
