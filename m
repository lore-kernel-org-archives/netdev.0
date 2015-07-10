From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] ipv6: Do not iterate over all interfaces when
 finding source address on specific interface.
Date: Fri, 10 Jul 2015 16:31:23 +0900
Message-ID: <559F74CB.4010109@miraclelinux.com>
References: <559F6B2E.8010408@miraclelinux.com> <CAAedzxpD7EEV-3BXdGA72wqwxM1b0tge0iqBKehfZG4KvRjYrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34402 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbbGJHb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 03:31:27 -0400
Received: by pdbep18 with SMTP id ep18so179736246pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 00:31:27 -0700 (PDT)
In-Reply-To: <CAAedzxpD7EEV-3BXdGA72wqwxM1b0tge0iqBKehfZG4KvRjYrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Erik Kline wrote:

>> +       /* Candidate Source Address (section 4)
>> +        *  - multicast and link-local destination address,
>> +        *    the set of candidate source address MUST only
>> +        *    include addresses assigned to interfaces
>> +        *    belonging to the same link as the outgoing
>> +        *    interface.
>> +        * (- For site-local destination addresses, the
>> +        *    set of candidate source addresses MUST only
>> +        *    include addresses assigned to interfaces
>> +        *    belonging to the same site as the outgoing
>> +        *    interface.)
>> +        *  - "It is RECOMMENDED that the candidate source addresses
>> +        *    be the set of unicast addresses assigned to the
>> +        *    interface that will be used to send to the destination
>> +        *    (the 'outgoing' interface)." (RFC 6724)
>> +        */

Sorry, I forgot to remove 3rd one, which should be removed for now; I'll
resubmit.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
