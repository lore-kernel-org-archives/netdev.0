From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Wed, 6 May 2015 11:15:18 -0700
Message-ID: <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de>
	<1958390.Ugr57PpLDS@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1958390.Ugr57PpLDS@h2o.as.studentenwerk.mhn.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev.)

On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wrote:
> Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
>> Hello,
>>
>> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute6 with an
>> isatap-tunnel.
>
> I did some further tests. To trigger the crash you need
>
> * isatap-tunnel (probably any sit-tunnel will do it)
> * raw-socket
> * udp
>
> Using icmpv6 or tcp i.e. does not trigger it.
>

Do you have a script to reproduce it?


Thanks for the bug report!
