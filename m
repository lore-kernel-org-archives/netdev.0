From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: forwarding IPv6 LL packets, bug?
Date: Tue, 24 Feb 2015 14:27:02 +0900
Message-ID: <54EC0BA6.5010305@miraclelinux.com>
References: <20150222164341.GD28830@stevemcqueen.digriz.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Alexander Clouter <alex@digriz.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:52302 "HELO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750733AbbBXF1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 00:27:06 -0500
Received: by mail-pa0-f47.google.com with SMTP id rd3so33276939pab.4
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 21:27:05 -0800 (PST)
In-Reply-To: <20150222164341.GD28830@stevemcqueen.digriz.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Alexander Clouter wrote:
> If this was not link-local addresses then Linux would be doing exactly as I expected, however, I do not believe it should be forwarding as this is an IPv6 LL destination?

It is expected to forward packets with link-local destination
address if the destination is on the same link.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
