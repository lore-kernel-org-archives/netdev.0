From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: ping takes much time to myself?
Date: Mon, 26 Apr 2004 12:02:29 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0404261159510.1494@chaos>
References: <20040426154437.67657.qmail@web41402.mail.yahoo.com>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: net dev <netdev@oss.sgi.com>, kernerl mail <linux-kernel@vger.kernel.org>,
        linux net <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Parag Nemade <cranium2003@yahoo.com>
In-Reply-To: <20040426154437.67657.qmail@web41402.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Apr 2004, Parag Nemade wrote:

> hello,
>      i want to add my own variables with icmp header.
> so i modified icmp header and added 2 variables to
> make icmp header len is 16 bytes. but when i build
> kernel image and boot it and then ping to myself why
> am i still getting 8 bytes header i.e. 84 bytes packet
> and why not 92 bytes packet?
> 56 bytes data + 16 bytes icmp header + 20 bytes ip
> header = 92 bytes
> also ping results shown below takes much time to ping
> myself. what gone wrong? how to make it behave like
> normal ping?


You don't modify the kernel to make a new ICMP packet!
You modify `ping` or make your own. If you change the
length of the header, it is no longer ICMP. Your
tools will misinterpret what you have.

Cheers,
Dick Johnson
Penguin : Linux version 2.4.26 on an i686 machine (5557.45 BogoMips).
            Note 96.31% of all statistics are fiction.
