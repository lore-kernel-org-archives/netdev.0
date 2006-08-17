From: "John Que" <qwejohn@gmail.com>
Subject: time stamps of skb packets in NF_HOOKS callbacks
Date: Thu, 17 Aug 2006 17:37:15 +0300
Message-ID: <ada605fb0608170737m4c0096c4u33a70dcf37e09df8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:29516 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932427AbWHQOhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 10:37:16 -0400
Received: by nf-out-0910.google.com with SMTP id o25so990229nfa
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 07:37:15 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I am using NF_HOOKS (a "PRE_ROUTING" hook).
When I try to print the time stamps (sec and usec) of skb packets
which I recieve
in the hook callback I get 0. Other skb fileds are correct.
According to my understanding, the time stamp should be updated
when the packet is received. Isn't it so ? Any idea why am I getting
"0" for tstamp fields (tstamp is a field in sk_buff and is  an intance
of skb_timeval).
(what I mean is that the values of skb->tstamp.off_sec and
skb>tstamp.off_usec are both 0 , for ongoing incoming packets)
Regards,
John
