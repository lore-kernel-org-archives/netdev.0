From: "Love, Robert W" <robert.w.love@intel.com>
Subject: Re: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Thu, 23 Aug 2012 18:15:00 +0000
Message-ID: <50367309.3080306@intel.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
 <1345760873-12101-7-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"dm@chelsio.com" <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chethan@chelsio.com" <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1345760873-12101-7-git-send-email-naresh@chelsio.com>
Content-Language: en-US
Content-ID: <AEC440C4E5872845814729F14CF3E8BE@intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/2012 3:27 PM, Naresh Kumar Inna wrote:
> This patch contains the first set of the header files for csiostor driver.
>
> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> ---
>   drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
>   drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++

I think most of these protocol definitions can be found in 
include/scsi/fc/ and possibly incluse/scsi/scsi_transport_fc.h. I think 
any protocol stuff missing should be added to the common header files.

Thanks, //Rob