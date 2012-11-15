From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [v6 PATCH 1/8] cxgb4/cxgb4vf: Chelsio FCoE offload driver submission
 (common header updates).
Date: Thu, 15 Nov 2012 17:02:11 +0530
Message-ID: <50A4D2BB.90100@chelsio.com>
References: <1351158621-32222-1-git-send-email-naresh@chelsio.com>  <1351158621-32222-2-git-send-email-naresh@chelsio.com> <1352860008.28921.2.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1352860008.28921.2.camel@dabdike>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2012 7:56 AM, James Bottomley wrote:
> On Thu, 2012-10-25 at 15:20 +0530, Naresh Kumar Inna wrote:
>> This patch contains updates to firmware/hardware header files shared
>> between csiostor and cxgb4/cxgb4vf, and the resulting changes to the
>> cxgb4/cxgb4vf source files.
>>
>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>> ---
>>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++--
>>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |    6 ++--
>>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   20 +++++-----
>>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
>>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   36 +++++++++++++++++++-
>>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   41 ++++++++++++++++++++---
>>  drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |    8 ++--
>>  7 files changed, 92 insertions(+), 28 deletions(-)
> 
> This still doesn't compile:
> 
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function adap_init0:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:3932:10: error: struct fw_caps_config_cmd has no member named retval_len16
> make[5]: *** [drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.o] Error 1
> 
> James
> 
> 
> 

This must have been caused by a recent pull - it used to build fine at
the time I sent this patch set for review.

I will send out another patch-set to address the build failure.

Thanks,
Naresh.
