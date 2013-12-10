From: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Tue, 10 Dec 2013 07:55:02 +0100
Message-ID: <52A6BAC6.4090407@samsung.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
 <1386603119.30495.331.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1386603119.30495.331.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

W dniu 09.12.2013 16:31, Eric Dumazet pisze:
> On Mon, 2013-12-09 at 12:47 +0100, Andrzej Pietrasiewicz wrote:
>> NOT FOR COMMITTING TO MAINLINE.
>>
>> With g_ether loaded the sk occasionally becomes 0xffffffff.
>> It happens usually after transferring few hundreds of kilobytes to few
>> tens of megabytes. If sk is 0xffffffff then dereferencing it causes
>> kernel panic.
>>
>> This is a *workaround*. I don't know enough net code to understand the core
>> of the problem. However, with this patch applied the problems are gone,
>> or at least pushed farther away.
>
> Is it happening on SMP or UP ?

UP build, S5PC110

>
> Crash should happen earlier in __inet_lookup_established()
>
>
>

AP
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
