From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] bridge: increase mtu to 9000
Date: Tue, 23 Feb 2016 08:51:31 +0800
Message-ID: <CAJFZqHztOjkRMcmJUw8r=aKD6sop5xVt33XFctPMGAbJJN5LEA@mail.gmail.com>
References: <1456133351-10292-1-git-send-email-roy.qing.li@gmail.com>
	<20160222095808.72edd4f9@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34620 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866AbcBWAvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 19:51:32 -0500
Received: by mail-oi0-f51.google.com with SMTP id m82so67739716oif.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 16:51:31 -0800 (PST)
In-Reply-To: <20160222095808.72edd4f9@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 1:58 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>> guest VMs.
>>
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>
> Your change works, but I agree with Hannes. Just allow up to 64 * 1024 like
> loopback does.  And no need for a #define for that it is only in one place.



thanks, I will change it as you suggest

-Roy
