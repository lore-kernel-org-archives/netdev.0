From: Chad Reese <kreese@cavium.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 07 Jul 2014 14:08:57 -0700
Message-ID: <53BB0C69.6000304@cavium.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com> <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain> <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com> <20140707184700.GA1610@localhost.localdomain> <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com> <53BAF8AC.6010907@cavium.com> <20140707201817.GA10683@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57705 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbaGGVJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 17:09:00 -0400
Received: by mail-ie0-f180.google.com with SMTP id tr6so2233756ieb.39
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 14:08:59 -0700 (PDT)
In-Reply-To: <20140707201817.GA10683@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2014 01:18 PM, Richard Cochran wrote:
> On Mon, Jul 07, 2014 at 12:44:44PM -0700, Chad Reese wrote:
>>
>> For Octeon, you can optionally use the hardware timestamp as the
>> system clock reference. Most people don't, but it is the only way to
>> get the system time to be accurate. 1588 can synchronize two Octeon
>> boards to less than 1ns for the hardware timer. The Linux software
>> timers is always farther off.
>
> Did you mean 1us ?

No, it was 1ns. Who would go through all this effort if all you wanted 
was 1us?  Our requirement was within 20ns, but me managed to get 1ns 
with a lab setup. We had to be careful that the scope probes used in the 
measurement were the same length.

Chad

-- 

Chad Reese <kreese@cavium.com>
Cavium Networks
Phone: 408 - 943 - 7183
Cell: 321 - 438 - 7753
