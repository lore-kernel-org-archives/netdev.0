From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: Re: [PATCH] bridge:Fix incorrect variable assignment on error path in
 br_sysfs_addbr
Date: Mon, 4 Apr 2016 16:16:45 -0400
Message-ID: <5702CBAD.1030900@gmail.com>
References: <1459724666-3666-1-git-send-email-bastienphilbert@gmail.com>
 <20160404.161418.1551441547560943567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34846 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbcDDUQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 16:16:48 -0400
In-Reply-To: <20160404.161418.1551441547560943567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016-04-04 04:14 PM, David Miller wrote:
> From: Bastien Philbert <bastienphilbert@gmail.com>
> Date: Sun,  3 Apr 2016 19:04:26 -0400
> 
>> This fixes the incorrect variable assignment on error path in
>> br_sysfs_addbr for when the call to kobject_create_and_add
>> fails to assign the value of -EINVAL to the returned variable of
>> err rather then incorrectly return zero making callers think this
>> function has succeededed due to the previous assignment being
>> assigned zero when assigning it the successful return value of
>> the call to sysfs_create_group which is zero.
>>
>> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
> 
> Applied, but please put a space after the subsystem prefix and the
> colon character in your subject lines in the future.
> 
> Doesn't that really look odd to you, the way you did it? "net:Fix"?
> 
> Doesn't it look more natural, and consistent with what all other
> patch submitters do, if it's "net: Fix"?
> 
> Thanks.
> 
Done, sorry about that :(. Will remember for future patches.
Bastien
