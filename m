From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 03/10] net: Update remote checksum segmentation
 to support use of GSO checksum
Date: Sun, 7 Feb 2016 04:13:53 -0600
Message-ID: <CAKgT0UcfzuEH7EzF9krziDQ1r_t3_LVTRNMvJxaQ60-HzypLyQ@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232743.18529.68800.stgit@localhost.localdomain>
	<CALx6S35J9SJp_btTiDBL703BRxNPkYMV0bNdTqRkdafGyHYEHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34548 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbcBGKNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:13:54 -0500
Received: by mail-ig0-f196.google.com with SMTP id ik10so3413296igb.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 02:13:53 -0800 (PST)
In-Reply-To: <CALx6S35J9SJp_btTiDBL703BRxNPkYMV0bNdTqRkdafGyHYEHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 6, 2016 at 2:44 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Feb 5, 2016 at 3:27 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch addresses two main issues.
>>
>> First in the case of remote checksum offload we were avoiding dealing with
>> scatter-gather issues.  As a result it would be possible to assemble a
>> series of frames that used frags instead of being linearized as they should
>> have if remote checksum offload was enabled.
>>
>> Second I have updated the code so that we now let GSO take care of doing
>> the checksum on the data itself and drop the special case that was added
>> for remote checksum offload.
>>
> Did you test this (with vxlan or GUE)?

I was testing with VXLAN.

- Alex
