From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 10:07:57 -0500
Message-ID: <C6E2C6E1-A4DA-45F8-A94F-D3B78AFA018F@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop> <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com> <1324616007.2674.8.camel@edumazet-laptop> <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com> <1324617390.2674.13.camel@edumazet-laptop> <1324618555.10854.4.camel@edumazet-laptop> <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com> <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <EC59D18E-82F6-4409-BB29-D7434D63B0C9@gmail.com> <1324652031.2223.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44254 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab1LWPIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 10:08:02 -0500
Received: by iaeh11 with SMTP id h11so15218700iae.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 07:08:01 -0800 (PST)
In-Reply-To: <1324652031.2223.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 23, 2011, at 9:53 AM, Eric Dumazet wrote:
> Unsigned arithmetics is well defined in C. Very well in fact.

Oversized shifts are undefined in C, no matter it is unsigned
or not; roundup_pow_of_two() is implemented by shifting.

>> BTW, (count > UINT_MAX) is shorter and easier to understand
>> than (count != (unsigned long)(u32)count).
> 
> You miss the point. UINT_MAX is too small for 64bit arches.

I am sorry why is it too small?  what's difference between
(count > UINT_MAX) and (count != (unsigned long)(u32)count)?

- xi
