From: rapier <rapier@psc.edu>
Subject: Re: size of data_segs_[in|out] and segs_[in|out]
Date: Tue, 9 Aug 2016 13:17:59 -0400
Message-ID: <e0a3f13a-f3cc-8455-8e7d-9c604f8ef4fb@psc.edu>
References: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
 <20160808.160245.2063863440275871547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:34586 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932360AbcHISLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 14:11:00 -0400
In-Reply-To: <20160808.160245.2063863440275871547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/8/16 7:02 PM, David Miller wrote:
> From: rapier <rapier@psc.edu>
> Date: Mon, 8 Aug 2016 18:02:29 -0400
>
>> As such, would it be feasible to define these instruments as 64bit
>> instead of 32bit? If so, a cursory look at the code seems to indicate
>> that this would only require a change in the header files.
>
> It would break every application looking at these datastructures
> right now.

I cannot deny that would be a problem but conversely, those applications 
are currently in a position where they may be depending on inaccurate 
data. I'm not advocating breaking things for the sake of breaking things 
but my feeling is that this will eventually need to be addressed. Since 
the segs datastructure is a relatively recent addition it might make 
sense to make that change now before it's even more baked in to other 
applications.
