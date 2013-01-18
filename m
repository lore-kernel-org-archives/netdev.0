From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
Date: Fri, 18 Jan 2013 01:13:30 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1843ABB7F00@ORSMSX102.amr.corp.intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130117075626.40eb1500@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24289 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963Ab3ARBNc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 20:13:32 -0500
In-Reply-To: <20130117075626.40eb1500@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Thursday, January 17, 2013 7:56 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Allan, Bruce W; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com; Richard Cochran
> Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
> 
> On Thu, 17 Jan 2013 03:35:09 -0800
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > +static struct ptp_clock_info e1000e_ptp_clock_info = {
> 
> Should be static const since it is immutable and contains function pointers.

Nice catch!  Thanks for the review Stephen.  I'll submit a follow-on patch to change this
if that is alright with you.  Btw, did you catch that through inspection or did you use a
static analysis tool?

Bruce.
