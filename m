From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: some failures with vxlan offloads..
Date: Mon, 27 Oct 2014 00:23:14 +0200
Message-ID: <CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>
References: <544CF8E3.8070207@mellanox.com>
	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:60385 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbaJZWXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 18:23:15 -0400
Received: by mail-ob0-f179.google.com with SMTP id m8so418427obr.24
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 15:23:14 -0700 (PDT)
In-Reply-To: <CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2014 at 5:29 PM, Tom Herbert <therbert@google.com> wrote:
> On Sun, Oct 26, 2014 at 6:36 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:

>> In the cases where it breaks I can see
>>         UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789
>> ulen 726
>> prints from __udp4_lib_rcv() in the kernel log of the node where offloads
>> are OFF, where the bad packet is sent from the host where offloading is
>> enabled. I guess the packet is just dropped:

> Can you determine what the TSO HW engine is setting in UDP checksum
> field? tcpdump -vv might be able to show this. The symptoms seem to
> indicate that it may not be zero.

Thanks for the quick response. I'll check what is placed in the UDP
checksum field for packets that went through the offloading HW and let
you know.

BTW, if following the direction you proposed, I wonder why this works
(e.g the kernel doesn't drops the encapsulated TCP packets) when both
sides are offloaded?

Tomorrow (Monday) I am OOO so will be able to do these further tests Tuesday.

Or.
