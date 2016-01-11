From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-net V2 00/12] net/mlx5_core: Enhance flow steering support
Date: Mon, 11 Jan 2016 10:24:54 +0200
Message-ID: <CAJ3xEMjEd9cxn6GLOWd_bzzWoMgmrsNZwOMSsznMayWzmnZMuQ@mail.gmail.com>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
	<20160110.170524.1947409913228474436.davem@davemloft.net>
	<CAJ3xEMgxFQszmhWBZmWqfscOBkY8E5JuieXAs86szfeap84EhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>, maorg@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33888 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcAKIYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 03:24:55 -0500
Received: by mail-ig0-f195.google.com with SMTP id ik10so12541675igb.1
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 00:24:55 -0800 (PST)
In-Reply-To: <CAJ3xEMgxFQszmhWBZmWqfscOBkY8E5JuieXAs86szfeap84EhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 6:15 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Jan 11, 2016 at 12:05 AM, David Miller <davem@davemloft.net> wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>> Date: Sun, 10 Jan 2016 10:39:37 +0200
>>
>>> v1 --> v2 changes:
>>>   - made sure that service functions added in the IB driver are only static-fied
>>>     on the last commit, to make sure bisection with -Werror works fine.
>>
>> Please don't do this.  This looks rediculous.
>
>> Instead, if this kind of dependency exists in a source file, simply
>> add the new functions in the same commit that adds the usage of
>> them.
>
> OKay, we did that to get better breakup of the patches to smaller
> units, will squash the last two patches and respin


Dave,

Since this series was in progress and no notable comments are pending
beyond that little squash, I thought it could be OK to make that re-spinning
now, so this does meet 4.5-rc1, hope you're fine with that.

Or.
