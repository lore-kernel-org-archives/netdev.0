From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-net V2 00/12] net/mlx5_core: Enhance flow steering support
Date: Mon, 11 Jan 2016 06:15:37 +0200
Message-ID: <CAJ3xEMgxFQszmhWBZmWqfscOBkY8E5JuieXAs86szfeap84EhQ@mail.gmail.com>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
	<20160110.170524.1947409913228474436.davem@davemloft.net>
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
Received: from mail-ig0-f194.google.com ([209.85.213.194]:32951 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758135AbcAKEPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 23:15:38 -0500
Received: by mail-ig0-f194.google.com with SMTP id y8so12227657igw.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 20:15:38 -0800 (PST)
In-Reply-To: <20160110.170524.1947409913228474436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 12:05 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun, 10 Jan 2016 10:39:37 +0200
>
>> v1 --> v2 changes:
>>   - made sure that service functions added in the IB driver are only static-fied
>>     on the last commit, to make sure bisection with -Werror works fine.
>
> Please don't do this.  This looks rediculous.

> Instead, if this kind of dependency exists in a source file, simply
> add the new functions in the same commit that adds the usage of
> them.

OKay, we did that to get better breakup of the patches to smaller
units, will squash the last two patches and respin

Or.
