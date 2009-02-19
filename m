From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH 6/7] fcoe: remove ETH_P_FCOE from fc_fcoe.h
Date: Thu, 19 Feb 2009 13:49:24 -0800
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2222427B862@orsmsx509.amr.corp.intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
	<20090219195022.22270.8543.stgit.yi.zou@intel.com>
 <20090219132517.08bb6f51@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090219132517.08bb6f51@extreme>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>On Thu, 19 Feb 2009 12:50:23 -0700
>Yi Zou <yi.zou@intel.com> wrote:
>
>> No need to have ETH_P_FCOE in fc_fcoe.h as it is now defined in
>if_ether.h
>>
>> Signed-off-by: Yi Zou <yi.zou@intel.com>
>> ---
>>
>>  include/scsi/fc/fc_fcoe.h |    7 -------
>>  1 files changed, 0 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/scsi/fc/fc_fcoe.h b/include/scsi/fc/fc_fcoe.h
>> index f271d9c..ccb3dbe 100644
>> --- a/include/scsi/fc/fc_fcoe.h
>> +++ b/include/scsi/fc/fc_fcoe.h
>> @@ -25,13 +25,6 @@
>>   */
>>
>>  /*
>> - * The FCoE ethertype eventually goes in net/if_ether.h.
>> - */
>> -#ifndef ETH_P_FCOE
>> -#define     ETH_P_FCOE      0x8906          /* FCOE ether type */
>> -#endif
>> -
>>
>Just do the move from fc_fcoe.h to if_ether.h in one patch.
Good point, I'll fix that.

Thanks.
yi
