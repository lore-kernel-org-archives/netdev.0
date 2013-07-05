From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 'rmmod -f ipv6': BUG: unable to handle kernel paging request
Date: Fri, 5 Jul 2013 09:17:22 +0800
Message-ID: <CAM_iQpWPDH3XGjtHXAjBjtp2bBfqKC6YPK=R_rGDMV0rjrgaxw@mail.gmail.com>
References: <20130704210434.GA6381@Linus-Debian>
	<20130704.142951.1908678475285188106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linus.luessing@web.de,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130704.142951.1908678475285188106.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 5, 2013 at 5:29 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Linus L=C3=BCssing <linus.luessing@web.de>
> Date: Thu, 4 Jul 2013 23:04:34 +0200
>
>> When trying to perform a forceful unload of an ipv6 kernel module
>> on a 3.10 kernel then I'm getting a kernel panic with the attached
>> trace.
>>
>> Is this supposed to happen due to the '-f' option or is this a bug
>> in the ipv6 code?
>
> The ipv6 module is not capable of being unloaded, sorry.
>

If so, we should remove inet6_exit()...
