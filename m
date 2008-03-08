From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: DoS by cat /proc/net/ip_conntrack ?
Date: Sat, 08 Mar 2008 13:26:41 +0100
Message-ID: <47D28601.4080106@gmail.com>
References: <20080306134037.M70019@visp.net.lb> <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:63557 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbYCHMUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 07:20:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1024863fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 04:20:36 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote, On 03/06/2008 02:51 PM:

> 
> On Thu, 6 Mar 2008, Denys Fedoryshchenko wrote:

...

>> i tried to issue command cat /proc/net/ip_conntrack |grep 'something'
>>
>> Router went dead for about 2 minutes, even i disconnect ssh session.
...
>> I dont think it is normal, and such command taking a lot of system resources
>> and cause whole system to hang.
>>
>> Kernel 2.6.24.2
> 
> The answer is quite simple here: don't do this. Instead use "conntrack -L" 
> as netlink is much more effective and better designed.


I think, Denys is concerned about some other, maybe too curious users
if they can read this?

Regards,
Jarek P.
