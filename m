From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 11:05:33 -0600
Message-ID: <55E4895D.2060202@cumulusnetworks.com>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
 <CALx6S379ZrcKdapJ0yRwzyW-ACY=45DcJnUNJ6mRZPjJAie1VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33079 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbbHaRFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:05:39 -0400
Received: by igbuu8 with SMTP id uu8so51254391igb.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:05:38 -0700 (PDT)
In-Reply-To: <CALx6S379ZrcKdapJ0yRwzyW-ACY=45DcJnUNJ6mRZPjJAie1VA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/15 11:02 AM, Tom Herbert wrote:
> On Mon, Aug 31, 2015 at 9:29 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> Remove the VRF change in udp_sendmsg to set the source address. The VRF
>> driver already has access to the packet on the TX path via the dst. It
>> can be used to update the source address in the header.
>>
>
> I don't understand this. The previous code was about selecting a
> source address for packets being sourced ed on a socket, but this new
> patch seems to essentially be doing SNAT in the VRF transmit path
> which  seems like a fundamentally different behavior. Is this really
> your intention?
>

The original code and this new code are only controlling FIB lookups 
which in turn set the source address. Functionally both versions do the 
same thing.

David
