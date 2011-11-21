From: Alexey Moiseytsev <himeraster@gmail.com>
Subject: Re: [bug] af_unix: Reading from a stream socket may lock the concurrent
 poll() call
Date: Tue, 22 Nov 2011 03:34:01 +0400
Message-ID: <4ECADFE9.9030705@gmail.com>
References: <CAHjqzy7dhqi22yPJX=DP4x916hVXDY2WaDbdmnTEQ54n6qpMXw@mail.gmail.com> <20111120.153156.1383147368726575639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111120.153156.1383147368726575639.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

21.11.2011 00:31, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Alexey Moiseytsev<himeraster@gmail.com>
> Date: Mon, 21 Nov 2011 00:19:02 +0400
>
>> Other info:
>> $ uname -srmo
>> Linux 2.6.32-5-amd64 x86_64 GNU/Linux
>
> There have been numerous AF_UNIX bug fixes since that release, please=
 try
> to reproduce your problem with current kernels.
>

I upgraded kernel up to 3.2-rc2 but the problem still exists.
