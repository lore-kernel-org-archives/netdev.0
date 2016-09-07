From: Daniel Walker <danielwa@cisco.com>
Subject: Re: ptp
Date: Wed, 7 Sep 2016 13:55:19 -0700
Message-ID: <85389e04-76ad-9a19-2a33-d49a9bdd8452@cisco.com>
References: <d1b2b740-8cc6-bf4a-722b-7b323fb0c7c0@cisco.com>
 <20160907204818.GA7470@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>,
        Shabeena Shabeena -X "(sshabeen" - ARICENT TECHNOLOGIES
         MAURIITIUS LIMITED at "Cisco)" <sshabeen@cisco.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:57345 "EHLO
        rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbcIGVEq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 17:04:46 -0400
In-Reply-To: <20160907204818.GA7470@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2016 01:48 PM, Richard Cochran wrote:
> On Wed, Sep 07, 2016 at 01:40:59PM -0700, Daniel Walker wrote:
>> There is a test (below) , which prevents negative nanosecond updates. The
>> code below would force a negative update to always return more than
>> NSEC_PER_SEC. It should be using abs() instead which would return the value
>> desired.
> No.  This:
>
> 	/*
> 	 * The value of a timeval is the sum of its fields, but the
> 	 * field tv_usec must always be non-negative.
> 	 */
>
> HTH,
> Richard


So the code only allows second granularity negative updates, or the 
seconds component is the only part which needs to actually be negative ?


Daniel
