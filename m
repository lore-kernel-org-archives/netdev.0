From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH RFC] igb: Fix false positive return of
 igb_get_auto_rd_done for 82580
Date: Wed, 6 Jul 2011 08:28:03 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F0172619A6A@orsmsx508.amr.corp.intel.com>
References: <1308682969-20690-1-git-send-email-guenter.roeck@ericsson.com>
 <1308691047.22851.60.camel@jtkirshe-mobl>
 <20110705143105.GA27454@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tong Ho <tong.ho@ericsson.com>
To: Guenter Roeck <guenter.roeck@ericsson.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33675 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895Ab1GFP2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:28:05 -0400
In-Reply-To: <20110705143105.GA27454@ericsson.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Guenter Roeck [mailto:guenter.roeck@ericsson.com]
>Sent: Tuesday, July 05, 2011 7:31 AM
>To: Kirsher, Jeffrey T
>Cc: Brandeburg, Jesse; Wyborny, Carolyn; Duyck, Alexander H; Ronciak,
>John; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; Tong Ho
>Subject: Re: [PATCH RFC] igb: Fix false positive return of
>igb_get_auto_rd_done for 82580
>
>On Tue, Jun 21, 2011 at 05:17:26PM -0400, Jeff Kirsher wrote:
>> On Tue, 2011-06-21 at 12:02 -0700, Guenter Roeck wrote:
>> > From: Tong Ho <tong.ho@ericsson.com>
>> >
>> > 82580 re-reads the port specific portion of eeprom after port reset.
>> > If called immediately after a reset, igb_get_auto_rd_done() returns
>> > false positive because the done bit has yet to transition from 1 to
>0.
>> >
>> > Add wrfl() immediately after resetting 82580 port or device,
>> > plus a 1ms delay, to avoid the problem.
>> >
>> > Signed-off-by: Tong Ho <tong.ho@ericsson.com>
>> > Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
>> > ---
>> > Sent as RFC since I am not entirely sure if the solution is the
>> > correct one
>> > to address the problem we are seeing. If there is a better solution,
>> > please
>> > let me know.
>>
>> Thank you for the suggested patch.  Carolyn is the maintainer for igb
>> and we will look into this issue you are seeing and the suggested fix.
>
>Hi Jeff and Carolyn,
>
>Any update ?
>
>Thanks,
>Guenter

Sorry for the delay, we've had some holidays, its just passed internal testing and should be coming upstream shortly.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation


