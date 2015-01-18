From: Miquel van Smoorenburg <mikevs@xs4all.net>
Subject: Re: net: prevent of emerging cross-namespace symlinks patches for
 3.14?
Date: Mon, 19 Jan 2015 00:17:06 +0100
Message-ID: <54BC3EF2.5080403@xs4all.net>
References: <54B6E36F.9060703@xs4all.net> <CAChDUfTktt7DAg+Mi0+PWcykhHWvE9wg5FNieWUuoBjZGsU8jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Alexander Y. Fomichev" <git.user@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAChDUfTktt7DAg+Mi0+PWcykhHWvE9wg5FNieWUuoBjZGsU8jQ@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/01/15 19:39, Alexander Y. Fomichev wrote:
> On Thu, Jan 15, 2015 at 12:45 AM, Miquel van Smoorenburg mikevs@xs4all.net> wrote:
>> [first sent to lkml, now to netdev and the original patch author]
>>
>> When running 'lxc' on the latest -stable kernel, 3.14.28, I'm seeing these
>> errors:
>>
>> Jan 14 17:47:16 lxc2 kernel: [   10.704892] sysfs: cannot create duplicate
>> filename '/devices/virtual/net/eth0.104/upper_eth0'
>> I did not see these errors in 3.12. This was fixed in 3.17
>
> Hi,
>
> no objections of course,
> actually it was written and tested with 3.14 in mind.

David, could you have a quick look and ack this if you agree this should 
go in 3.14-stable ?

Thanks

Mike.
