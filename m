From: Miika Komu <miika@iki.fi>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Wed, 7 May 2008 12:51:15 +0300 (EEST)
Message-ID: <Pine.SOL.4.64.0805071247120.17745@kekkonen.cs.hut.fi>
References: <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
 <20080505.150045.29715304.yoshfuji@linux-ipv6.org>
 <Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi>
 <20080506.191848.37229806.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-342241519-1210153875=:17745"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twilight.cs.hut.fi ([130.233.40.5]:35070 "EHLO
	twilight.cs.hut.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbYEGJvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 05:51:18 -0400
In-Reply-To: <20080506.191848.37229806.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-342241519-1210153875=:17745
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 6 May 2008, YOSHIFUJI Hideaki / µÈÆ£±ÑÌÀ wrote:

Hi,

> In article <Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi> (at Tue, 6 May 2008 11:07:49 +0300 (EEST)), Miika Komu <miika@iki.fi> says:
>
>>> Miika, where are your other patches on top of this?
>>> This kind of change might be okay, but it must be along with
>>> its users, at least.
>>
>> we are maintaining a separate kernel module (GPLv2) for the HIP socket
>> handler for experimentation purposes. If you want to have a look it, you
>> can e.g. download the nightly tarball and have a look at the hipsock
>> directory:
>>
>> http://infrahip.hiit.fi/hipl/hipl.tar.gz
>
> Even though, we basically do not accept patches without in-kernel users.
>
> Anyway, I've quickly looked into the code, and IMHO
> it is better to avoid using hip_select_socket_handler() and
> to introduce new hip_ops (or something) in sock{}.

Ok.

> And, are you working on IPv4 transport?

The IPv6 socket interface is more useful for HIP-aware applications. We 
are implementing LSI support for non-hip-aware applications. The other HIP 
implementations (BSD HIP and Boeing) support already LSIs for 
non-hip-aware applications.

-- 
Miika Komu                                       http://www.iki.fi/miika/
---559023410-342241519-1210153875=:17745--
