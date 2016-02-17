From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 6/8] net: ixgbe: add minimal parser details
 for ixgbe
Date: Wed, 17 Feb 2016 06:06:02 -0500
Message-ID: <56C4541A.5070508@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051828.17139.51653.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35521 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161137AbcBQLGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:06:05 -0500
Received: by mail-io0-f176.google.com with SMTP id g203so32906884iof.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:06:04 -0800 (PST)
In-Reply-To: <20160217051828.17139.51653.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 12:18 AM, John Fastabend wrote:
> This adds an ixgbe data structure that is used to determine what
> headers:fields can be matched and in what order they are supported.
>
> For hardware devices this can be a bit tricky because typically
> only pre-programmed (firmware, ucode, rtl) parse graphs will be
> supported and we don't yet have an interface to change these from
> the OS. So its sort of a you get whatever your friendly vendor
> provides affair at the moment.
>
> In the future we can add the get routines and set routines to
> update this data structure. One interesting thing to note here
> is the data structure here identifies ethernet, ip, and tcp
> fields without having to hardcode them as enumerations or use
> other identifiers.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>


should __u32 be u32? Also at some points you seem to interchangeably
use unsigned int vs u32. I think most of unsigned ints should be u32.


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
