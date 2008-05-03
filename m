From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Sat, 3 May 2008 14:11:31 +0200
Message-ID: <20080503121130.GA2921@ami.dom.local>
References: <20080503071651.GA3313@ami.dom.local> <481C33D2.2090308@ya.bofh.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46251 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbYECMMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 08:12:38 -0400
Received: by nf-out-0910.google.com with SMTP id d3so827688nfc.21
        for <netdev@vger.kernel.org>; Sat, 03 May 2008 05:12:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <481C33D2.2090308@ya.bofh.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 11:43:46AM +0200, Jan 'yanek' Bortl wrote:
> Jarek Poplawski wrote:
>> Jan 'yanek' Bortl wrote, On 05/01/2008 05:49 PM:
>>
>>> Hi,
>>
>> Hi,
>>> I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:
>>
>> Does this mean the bug triggers in 2.6.25 and later, but not in 2.6.24?
>> If so, is it possible to reproduce this e.g. with 2.6.25-rc6?
>
> I firstly discovered this on 2.6.22-6~bpo40+1 (debian's backports), but 
> I'm not sure if that was same thing (it is long ago).
>
> Now i tested on test machine with these kernels:
> 2.6.24, 2.6.24.6  
> (http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/netconsole-2.6.24.6-slon.txt), 
> 2.6.25
>
> I can test anything you want.

Great! I really appreciate! You're very helpful in catching this rare
bug. Alas, there is still nothing obvious at least to me, so I need
more time for any idea...

BTW, one little doubt: are you really sure vanilla 2.6.24 (without .6
etc.) gives the same? (There were some changes backported from 2.6.25
which I'd like to exclude.)

Regards,
Jarek P.
