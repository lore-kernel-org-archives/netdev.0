From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: some failures with vxlan offloads..
Date: Wed, 29 Oct 2014 07:50:24 +0200
Message-ID: <54508020.1040305@mellanox.com>
References: <544CF8E3.8070207@mellanox.com>	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>	<CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>	<CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>	<544FB5CA.2060003@mellanox.com> <CA+mtBx_ncYrp_fbp8ucXfBaCoPpv_X+TEsmofCnpzTyPPfLXnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog132.obsmtp.com ([207.126.144.207]:33771 "EHLO
	eu1sys200aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226AbaJ2Fu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 01:50:29 -0400
In-Reply-To: <CA+mtBx_ncYrp_fbp8ucXfBaCoPpv_X+TEsmofCnpzTyPPfLXnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2014 5:36 PM, Tom Herbert wrote:
>> I wonder if we have another bug somewhere... when both sides were offloaded,
>> >it works even with the mlx4 bug, canyou explain that?is it possible that the
>> >GRO stack somehow covers on the bug when both sides are offloaded and
>> >GRO/VXLAN comes into play?
>>
> Look at the receive side. As I mentioned, if the device is returning
> checksum-unnecessary and setting csum_level to 1 (inner checksum was
> validated) then stack won't try to verify the outer checksum. So in
> this case if outer checksum is incorrect nobody complains about it.

OK, I'll look there. Anything that should worries us at that stack trace 
I sent in my initial email of this thread, or you think this is related 
to the mlx4 driver checksum bug?

Or.

>
