From: Chris Mason <clm@fb.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 11:33:33 -0500
Message-ID: <1416587613.24312.4@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:25957 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755084AbaKUQdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:33:38 -0500
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sALGThDC017332
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 08:33:37 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1qt0u31cwk-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 08:33:37 -0800
In-Reply-To: <20141121160937.GA32608@ret.masoncoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Nov 21, 2014 at 11:16 AM, Chris Mason <clm@fb.com> wrote:
> Hi everyone,
> 
> I've hit this a few times today while hammering on my btrfs queue for
> the next merge window.  It's plain v3.18-rc5 plus a few btrfs patches,
> so it isn't impossible a btrfs double free is causing trouble.

Looking through my console logs, I also hit it on v3.18-rc3 and on a 
test in the middle of the 3.18 merge window (don't have the exact sha, 
sorry).

-chris
