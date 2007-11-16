From: Patrick McHardy <kaber@trash.net>
Subject: Re: Null pointer dereference in nf_nat_move_storage(), kernel 2.6.23.1
Date: Fri, 16 Nov 2007 01:00:22 +0100
Message-ID: <473CDD96.6090102@trash.net>
References: <473B3874.2020104@redhat.com>	<473B83DB.5040303@redhat.com>	<20071115120658.GA17667@2ka.mipt.ru> <20071115.155509.107545186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, cebbert@redhat.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071115.155509.107545186.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 15 Nov 2007 15:06:59 +0300
>
>> Please test attached patch.
>>
>> This routing is called each time hash should be replaced, nf_conn has
>> extension list which contains pointers to connection tracking users
>> (like nat, which is right now the only such user), so when replace takes
>> place it should copy own extensions. Loop above checks for own
>> extension, but tries to move higer-layer one, which can lead to above
>> oops.
>>
>> Not tested, derived from code observation only.
>>
>> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>
> It looks extremely correct to me.  Therefore I'm going to apply
> this and queue it up for -stable.
>
> Thanks Evgeniy, keep up the excellent work!
>
> Patrick, please let me know if you have any objections.

The patch looks fine, thanks. I was just waiting for confirmation
from Chuck.


