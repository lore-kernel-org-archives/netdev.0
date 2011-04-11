From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
 physical identification
Date: Mon, 11 Apr 2011 16:30:43 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90018A2A30A9@orsmsx509.amr.corp.intel.com>
References: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
 <20110411162601.6686f169@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30856 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab1DKXap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 19:30:45 -0400
In-Reply-To: <20110411162601.6686f169@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Monday, April 11, 2011 4:26 PM
>To: Allan, Bruce W
>Cc: netdev@vger.kernel.org
>Subject: Re: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
>physical identification
>
>On Mon, 11 Apr 2011 16:16:35 -0700
>Bruce Allan <bruce.w.allan@intel.com> wrote:
>
>> When physical identification of an adapter is done by toggling the
>> mechanism on and off through software utilizing the .set_phys_id operation,
>> it is done with a fixed duration for both on and off states.  Some drivers
>> may want to set a custom duration for the on/off intervals.  This patch
>> changes the API so the return code from the driver's entry point can
>> specify the interval duration as a positive number; -EINVAL is still
>> allowed in order to use the default single on/off interval per second.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>
>IMHO this is -EOVERKILL.

I realize it does seem like that, but we have OEMs that expect the LEDs to
blink a certain way during a physical identification (twice a second vs.
once a second per the original .set_phys_id patchset).  There may be other
drivers from different hardware vendors that have similar but different
requirements.

