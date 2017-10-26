From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net 5/6] rtnetlink: check DO_SETLINK_NOTIFY correctly in
 do_setlink
Date: Thu, 26 Oct 2017 08:59:47 -0600
Message-ID: <200b14af-97eb-426e-8b82-3e5114e7bd1b@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
 <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
 <f3e88287-e2b8-06a9-a139-7a528749ef9e@gmail.com>
 <a783ef9d-e66c-b906-fcfd-4da5d560af9d@6wind.com>
 <0e37130c-bbf3-c75e-5cee-c3a08206873f@redhat.com>
 <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: nicolas.dichtel@6wind.com, vyasevic@redhat.com,
        Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:54938 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932246AbdJZO7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:59:51 -0400
Received: by mail-pf0-f169.google.com with SMTP id n89so2688215pfk.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 07:59:50 -0700 (PDT)
In-Reply-To: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 1:41 AM, Nicolas Dichtel wrote:
>> So I found this the first timer around when looking at this code, but was told that
>> notification are expected anytime we modified any setting thus the code was simply
>> checking for MODIFIED bit.  Has that thinking changed?
> No, you're right, thank you for pointing this out. I was focus on the duplicated
> notifications and forget the initial goal.
> 
> I will ask for a revert.

For everyone of the MODIFIED but not NOTIFY is there already a message
sent? If so, no revert is needed. If not, then perhaps those need the
NOTIFY bit set.
