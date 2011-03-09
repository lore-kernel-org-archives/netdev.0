From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Wed, 09 Mar 2011 11:38:48 +0800
Message-ID: <4D76F648.6040101@gmail.com>
References: <4D75D244.9070409@gmail.com> <il58p9$3ka$2@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36377 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117Ab1CIDm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 22:42:59 -0500
Received: by vxi39 with SMTP id 39so137821vxi.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 19:42:59 -0800 (PST)
In-Reply-To: <il58p9$3ka$2@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2011 08:51 PM, WANG Cong wrote:
> On Tue, 08 Mar 2011 14:52:52 +0800, Weiping Pan wrote:
>
>> ok, I use "Host-only mode" and get
>>
>>
>>
>> an conclusion, that if the first enslaved nic is pulled out, bonding
>> can't handle well.
>>
>> First test.
>> I first enslave eth6, then pull it out, bonding doesn't work. on host,
> ...
>>
>> Second test
>> I first enslave eth6, then pull eth7 out, bonding works well. on guest,
> Can you show me your /proc/net/bonding/bond0 before and after pulling down
> eth6 or eth7? And what does `ip link show` say?
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
And I test it again, there is no problem with kvm.
Maybe there is bug in virtualbox.

thanks
Weiping Pan
