From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH net-next-2.6] ixgbe: Use the instance of
	net_device_stats from net_device.
Date: Mon, 12 Oct 2009 16:28:56 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F12C29BFD9E@orsmsx501.amr.corp.intel.com>
References: <20091007124339.GA30083@serverengines.com>
 <EA929A9653AAE14F841771FB1DE5A1365F98A89A0B@rrsmsx501.amr.corp.intel.com>
 <20091012121055.GA10799@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ajit Khaparde <ajitk@serverengines.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:54431 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932650AbZJLX3l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 19:29:41 -0400
In-Reply-To: <20091012121055.GA10799@serverengines.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit Khaparde wrote:
> On 08/10/09 15:55 -0600, Tantilov, Emil S wrote:
>> Ajit Khaparde wrote:
>>> Since net_device has an instance of net_device_stats,
>>> we can remove the instance of this from the private adapter
>>> structure. 
>>> 
>>> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
>> 
>> I am seeing an issues with these patches where some counters are
>> messed up: 
>> 
> Thanks for testing the changes.
> There was an error in the way I was trying to offset for the netdev
> stats. 
> I have a fix for it now.  I would like to know if you would prefer an
> incremental patch or a patch with the previous changes too.
> I will mail the patches accordingly.  Sorry for the delay in sending
> this out. 
> 
> -Ajit

An incremental patch would probably be the best way to go since the previous changes were already accepted upstream.

Thanks,

Alex