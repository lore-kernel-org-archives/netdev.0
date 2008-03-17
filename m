From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Mon, 17 Mar 2008 11:44:11 +0100
Message-ID: <47DE4B7B.9040504@fr.ibm.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org> <47D98510.60801@imap.cc> <47D9A8DF.30809@fr.ibm.com> <47D9C1F0.6050803@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:31624 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbYCQKq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 06:46:59 -0400
In-Reply-To: <47D9C1F0.6050803@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tilman Schmidt wrote:
> Am 13.03.2008 23:21 schrieb Daniel Lezcano:
>> Tilman Schmidt wrote:
> 
>>> ts@xenon:~/kernel> /usr/sbin/sendmail -t < patch-usb-reduce-syslog-clutter-v3
>>> postdrop: warning: can't open /proc/net/if_inet6 (Permission denied) - skipping IPv6 configuration
>>> postdrop: fatal: parameter inet_interfaces: no local interface found for ::1
>>> sendmail: warning: command "/usr/sbin/postdrop -r" exited with status 1
>>> sendmail: fatal: ts(1000): unable to execute /usr/sbin/postdrop -r: Success
>>> ts@xenon:~/kernel>
>>>
>>> and unsurprisingly, the mail is not sent. If I do the same as root,
>>> everything works as usual, there is no console output from the
>>> sendmail command, and the mail goes out as it should. All other
>>> networking applications appear to be running normally.
> 
>> Is it possible to have your config file used to compile the kernel ?
> 
> Sure. You can find it at
> http://gollum.phnxsoft.com/~ts/linux/config-2.6.25-rc5-mm1

Thanks,

I was not able to reproduce it, but I think I didn't configured postfix 
as I should had. What version do you use ?
If I may ask you, can you put your postfix configuration file and a 
strace -f of your failing command ? on your website, that will help me a 
lot to investigate.

   -- Daniel
