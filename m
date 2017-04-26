From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: linux-next: Tree for Apr 26 (net/can/bcm.c)
Date: Wed, 26 Apr 2017 20:18:33 +0200
Message-ID: <9e4a2928-73b7-8ab0-c851-79fcb27569f4@hartkopp.net>
References: <20170426180321.3c8c16a2@canb.auug.org.au>
 <05bd24d8-6840-3551-a529-c464f3b26d0a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-can@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <05bd24d8-6840-3551-a529-c464f3b26d0a@infradead.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

thanks for the report!

Some fallout of my namespace support integration %-)

I posted a patch for it:

http://marc.info/?l=linux-can&m=149323049630039&w=2

Many thanks & best regards,
Oliver

On 04/26/2017 04:53 PM, Randy Dunlap wrote:
> On 04/26/17 01:03, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20170424:
>>
>
> on x86_64:
>
> when CONFIG_PROC_FS is not enabled:
>
> ../net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
> ../net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
> ../net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named 'bcmproc_dir'
> ../net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named 'bcmproc_dir'
>
> 2 of those are "protected" by
> 	if (IS_ENABLED(CONFIG_PROC_FS)) {
> but that doesn't seem to help/work here.
>
> gcc v4.8.5
>
>
>
