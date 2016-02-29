From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 01/13] RDS: Drop stale iWARP RDMA transport
Date: Sun, 28 Feb 2016 16:26:07 -0800
Message-ID: <56D3901F.3070405@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
 <1456625990-4739-2-git-send-email-santosh.shilimkar@oracle.com>
 <CAJ3xEMioB61bN9RAcAx9BecYGdWPs9QZNYUrm+r8=rt0WFMzKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39733 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbcB2A00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 19:26:26 -0500
In-Reply-To: <CAJ3xEMioB61bN9RAcAx9BecYGdWPs9QZNYUrm+r8=rt0WFMzKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/28/16 11:51 AM, Or Gerlitz wrote:
> On Sun, Feb 28, 2016 at 4:19 AM, Santosh Shilimkar
> <santosh.shilimkar@oracle.com> wrote:
>> RDS iWarp support code has become stale and non testable. As
>> indicated earlier, am dropping the support for it.
>>
>> If new iWarp user(s) shows up in future, we can adapat the RDS IB
>> transprt for the special RDMA READ sink case. iWarp needs an MR
>> for the RDMA READ sink.
>>
>> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>
> Hi, just wondered if there's any special reason that all this series
> carries double S.O.B signature line with your name appearing twice on
> two different email addresses?
>
Nothing special. I sign of all my patches with k.org id and have to
keep Oracle id as well being a payed Oracle employee. ;-)

Regards,
Santosh
