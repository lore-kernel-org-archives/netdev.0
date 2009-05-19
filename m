From: Avi Kivity <avi@redhat.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Tue, 19 May 2009 13:13:07 +0300
Message-ID: <4A128633.4060800@redhat.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>	<200905142128.58111.rusty@rustcorp.com.au> <4A0C2500.7090709@Voltaire.com> <4A0D14BF.5010409@msgid.tls.msk.ru> <4A12833B.4090804@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40297 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbZESKNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 06:13:21 -0400
In-Reply-To: <4A12833B.4090804@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
>> One solution to this is just to copy that file from kernel-2.6.29.  Or
>> maybe it's easier to add some -I flags to kvm compile commandline.
>>     
>
> This would not be enough since it needs also the virtio_net header and I'm not clear what version, the kernel one  on the one that comes with qemu... Now, all this comes into play only with the qemu provided by kvm releases since the savannah one doesn't have the code that uses TUNSETOFFLOAD, IFF_VNET_HDR etc.
>
> Avi - do you guys have some writeup / guidelines how to make all this work?
>  

Modern distros have this sewn up correctly.  For example my desktop runs 
kernel-2.6.27.21-170.2.56.fc10.x86_64, and has matching headers from 
kernel-headers-2.6.27.21-170.2.56.fc10.x86_64.

What are you using?


-- 
error compiling committee.c: too many arguments to function

