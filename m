From: rapier <rapier@psc.edu>
Subject: Re: size of data_segs_[in|out] and segs_[in|out]
Date: Tue, 9 Aug 2016 15:15:59 -0400
Message-ID: <e4365bea-e591-3041-14f8-4ecae7e91f75@psc.edu>
References: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
 <20160808.160245.2063863440275871547.davem@davemloft.net>
 <e0a3f13a-f3cc-8455-8e7d-9c604f8ef4fb@psc.edu>
 <20160809.120458.792987014914899369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:35641 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932322AbcHITQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 15:16:05 -0400
In-Reply-To: <20160809.120458.792987014914899369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/9/16 3:04 PM, David Miller wrote:
> From: rapier <rapier@psc.edu>
> Date: Tue, 9 Aug 2016 13:17:59 -0400
>
>> I cannot deny that would be a problem but conversely, those
>> applications are currently in a position where they may be depending
>> on inaccurate data. I'm not advocating breaking things for the sake of
>> breaking things but my feeling is that this will eventually need to be
>> addressed. Since the segs datastructure is a relatively recent
>> addition it might make sense to make that change now before it's even
>> more baked in to other applications.
>
> Changing the size or position of these data structure members is
> simply not an option.  It is locked into stone, and a permanent
> ABI which we cannot change.
>
> Please stop discussing as if changing this is a possibility.

I apologize, I wasn't aware of the constraints on this. There are other 
solutions available and I'll focus on those.
