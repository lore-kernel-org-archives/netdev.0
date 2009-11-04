From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [E1000-devel] [PATCH] e1000: the power down when running ifdown
	command
Date: Wed, 4 Nov 2009 09:57:04 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A903B3E19B8@orsmsx509.amr.corp.intel.com>
References: <4AEC05E8.40600@miraclelinux.com>
 <20091031105838.0d4b59a2@nehalam>	<4AEE35D2.4000503@miraclelinux.com>
	<4AF1562F.8010401@miraclelinux.com> <20091104080846.5bf4d225@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"svaidy@linux.vnet.ibm.com" <svaidy@linux.vnet.ibm.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4807 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757392AbZKDR5C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:57:02 -0500
In-Reply-To: <20091104080846.5bf4d225@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW, in e1000e the PHY is already powered down when the interface is brought down if WoL and manageability are disabled.  There is an issue where the PHY remains powered on when the driver is removed for which I have a patch already queued up here at Intel.

>-----Original Message-----
>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Wednesday, November 04, 2009 8:09 AM
>To: Naohiro Ooiwa
>Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; Brandeburg,
>Jesse; Ronciak, John; Kirsher, Jeffrey T; Andrew Morton;
>svaidy@linux.vnet.ibm.com; davem@davemloft.net
>Subject: Re: [E1000-devel] [PATCH] e1000: the power down when running
>ifdown command
>
>On Wed, 04 Nov 2009 19:23:43 +0900
>Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
>
>> Naohiro Ooiwa wrote:
>> > Stephen Hemminger wrote:
>> >> On Sat, 31 Oct 2009 18:39:52 +0900
>> >> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
>> >>
>> >> Does this work with Wake On Lan?
>> >
>> > Yes, it works WOL.
>>
>> Sorry, I made a mistake.
>> The WOL doesn't work when my patch applied to kernel.
>> I wasn't myself.
>>
>> I consider the WOL and I will resent the patch.
>> Thank you for your point.
>>
>>
>> thanks,
>> Naohiro Ooiwa
>
>
>Good, thank you for checking. I like the idea of powering down the
>PHY. Some of the drivers have shutdown hooks to power PHY back on
>during shutdown to enable WOL.
>
>
>--
>
>--------------------------------------------------------------------------
>----
>Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-
>Day
>trial. Simplify your report design, integration and deployment - and focus
>on
>what you do best, core application coding. Discover what's new with
>Crystal Reports now.  http://p.sf.net/sfu/bobj-july
>_______________________________________________
>E1000-devel mailing list
>E1000-devel@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/e1000-devel
