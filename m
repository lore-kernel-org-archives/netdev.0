From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Tue, 05 May 2015 15:31:03 -0400
Message-ID: <55491A77.70302@cumulusnetworks.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com> <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com> <309B89C4C689E141A5FF6A0C5FB2118B78DBE9D2@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35921 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbbEETbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 15:31:06 -0400
Received: by qku63 with SMTP id 63so113306150qku.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 12:31:05 -0700 (PDT)
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B78DBE9D2@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/15 1:25 PM, Brown, Aaron F wrote:
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Jonathan Toppins
>> Sent: Friday, April 17, 2015 1:24 PM
>> To: Kirsher, Jeffrey T
>> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
>> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
>> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
>> shm@cumulusnetworks.com; Alan Liebthal
>> Subject: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
>>
>> From: Alan Liebthal <alanl@cumulusnetworks.com>
>>
>> Support setting the MII register via SIOCSMIIREG.
>>
>> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
>> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>> ---
>>   drivers/net/ethernet/intel/igb/igb_main.c |    5 +++++
>>   1 file changed, 5 insertions(+)
>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>
Thanks Aaron, appreciate the testing.
