From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 18:20:43 +0900
Message-ID: <5524F2EB.4000908@miraclelinux.com>
References: <2142872.6QHf5ZAfZz@msg-id> <5524ED4F.9070907@miraclelinux.com> <1749676.NUxJ1eyH1x@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:59489 "HELO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751662AbbDHJUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 05:20:47 -0400
Received: by mail-pd0-f174.google.com with SMTP id qa5so51690462pdb.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 02:20:46 -0700 (PDT)
In-Reply-To: <1749676.NUxJ1eyH1x@msg-id>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salvatore Mesoraca wrote:
> YOSHIFUJI Hideaki wrote:
>> Hi,
> Hi,
> thank you for thaking to the time to answer
> 
>> Salvatore Mesoraca wrote:
>>> From: Vasiliy Kulikov <segooon@gmail.com>
>>>
>>> This patch adds non-raw IPPROTO_ICMP socket kind support that was added
>>> to the Linux 3.0.  The patch is backward-compatible: if ICMP socket kind
>>> is not enabled in the kernel (either in case of an old kernel or
>>> explicitly disabled via /proc/sys/net/ipv4/ping_group_range), ping uses
>>> old privileged raw sockets as a fallback.
>>>
>>> This patch is going to be included in Ubuntu 15.10 and it is already
>>> included in Gentoo stable tree (at the moment of the writing ping has
>>> CAP_NET_RAW still enabled by default) it is also included in OpenWall
>>> since 2011.
>>> This patch also tries to sneak in a fix for a missing colon in a printf.
>>> I've tested it on Linux 3.17.7 and it worked without issues.
>>
>> Please do not mix changes in a single commit.
>> Thanks.
> 
> I had some doubt about that additional change (it is so small that I don't 
> think that anyone will ever make a separate patch for it), but it was present 
> in the original patch and I decided to add it anyway and wait for feedback.
> I'll delete it.
> Thank you again for you comment.

What I meant was changes not for supporting non-raw icmp socket
should be formed separately.  It seems that the patch try to
change other things as well, in receive_error_msg() for example.

--yoshfuji

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
