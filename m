From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Sun, 13 Nov 2011 14:30:54 +0200
Message-ID: <1321187454.4651.1.camel@lb-tlvb-dmitry>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
 <1320938054-31288-10-git-send-email-dmitry@broadcom.com>
 <1320946787.2851.2.camel@bwh-desktop>
 <CAM8tLiMATfsH1mqmgrALX9o+5nWEahntCAc2ewm0RF_kbt=82A@mail.gmail.com>
 <CAM8tLiN=E2=a0TEYgw6mc70-vJU0dHjP4F4PpKUk8+3zvQPnAg@mail.gmail.com>
 <4EBC356A.6020907@intel.com>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dkravkov@gmail.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2244 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab1KMMbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:31:01 -0500
In-Reply-To: <4EBC356A.6020907@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-10 at 12:34 -0800, John Fastabend wrote:
> Use 'tc' to configure the mapping explicitly then. Or allow DCBnl
> set commands to be sent down either ieee_setets() or setpgtccfgtx()
> are used to configure priority to traffic class mappings. Then you
> could use a user space tool to set up all your DCB attributes without
> DCBX running (e.g. dcbtool/lldptol but I'm partial).
> 
> For example 'tc' commands,
> 
> # tc qdisc add dev eth3 root mqprio map 0 1 2 3 
> # tc qdisc add dev eth3 root mqprio help
> Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
>                   [queues count1@offset1 count2@offset2 ...] [hw 1|0]
> 
> It might be nice to add the ability to change the mapping after the tc
> has been created though. Maybe I'll get to this in the next week or
> two.
> 
John, thanks for the clarification and the example.

Dave, i will re-spin the sequence without the patch, soon.

Thanks all,
Dmitry
