From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next] sctp: change to use uint<size>_t in uapi sctp.h
Date: Thu, 16 Feb 2017 23:40:33 +0800
Message-ID: <CADvbK_c82TA+NETwPsMuTCx=k7tc9d6Wwi4yK5Y5NKOOVb5eTg@mail.gmail.com>
References: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
 <20170214.112604.827348279100654183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35211 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932120AbdBPPke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:40:34 -0500
In-Reply-To: <20170214.112604.827348279100654183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 12:26 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Tue, 14 Feb 2017 16:23:48 +0800
>
>> All structures in uapi sctp.h are exported for userspace, their members'
>> types should use uint<size>_t instead of __u<size>.
>
> This is not true.
>
> __u<size> is in fact preferred for userspace exported datastructures.
Hi, David, can you tell more details about uint<size>_t and __u<size>,
especially for usage of kernel and userspace in linux ?
or some documents about them.

Thanks.
