From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Does the ordering of the fib_table_dump or /proc/net/fib_trie
 matter?
Date: Tue, 06 Jan 2015 16:58:33 -0800
Message-ID: <54AC84B9.5020207@gmail.com>
References: <54AC45CE.80800@gmail.com> <20150106.165822.1294578064447416624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46208 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbAGA6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 19:58:36 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so1223950pab.6
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 16:58:35 -0800 (PST)
In-Reply-To: <20150106.165822.1294578064447416624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2015 01:58 PM, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Tue, 06 Jan 2015 12:30:06 -0800
>
>> The question I have is if that would screw up any user-space apps.  I
>> know ip route can dump the list via "ip route show".  I'm just wondering
>> if there would be any problem with default being the last entry instead
>> of the first entry?
> The ordering already changed once when we went from fib_hash to
> fib_trie, nobody should depend upon the ordering.

Okay good to hear.  I kind of thought that was the case, but I wanted to
make sure before I went too far down this rabbit hole.

Thanks.

- Alex
