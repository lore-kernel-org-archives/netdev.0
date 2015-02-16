From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Mon, 16 Feb 2015 10:31:41 +0800
Message-ID: <54E1568D.5000100@windriver.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com> <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com> <20150213212830.GA29912@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>,
	<sergei.shtylyov@cogentembedded.com>, <jonathon.reinhart@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64630 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbbBPCbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 21:31:43 -0500
In-Reply-To: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

When a user space application accesses the tun device by "ethtool " 
command, the returned default speed is 10M
while normal nic default speed is 1000M. The default tun speed 10M is 
somewhat odd compared with the default
speed 1000M.
Sometimes the user space application will treat this 10M as odd thing, 
then will send warnings to the administrator.
So I think maybe the default tun speed 1000M is better. The application 
will not send warnings.
In this case, this patch appears.

Best Regards!
Zhu Yanjun

On 02/14/2015 05:28 AM, Francois Romieu wrote:
> Zhu Yanjun <Yanjun.Zhu@windriver.com> :
>> The default speed of normal nic is 1000M while the default speed
>> of tun is 10M. Now the default speed of tun is changed to 1000M.
>> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
>> The command "ethtool -s tun0 speed 10/100/1000" can configure the
>> speed of tun dynamically.
> You don't explain why this patch is needed.
>
> Why should tun_set_settings filter speed this way/at all ?
>
> There's no reason to pollute uapi .h file.
>
