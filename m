From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: strange network slowness in 2.6 unless pingflooding
Date: Mon, 27 Sep 2004 17:37:58 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41587A26.6020606@conectiva.com.br>
References: <20040927090342.GA1794@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, jgarzik@pobox.com,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: CaT <cat@zip.com.au>
In-Reply-To: <20040927090342.GA1794@zip.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



CaT wrote:
> Hi,
> 
> This is still happening. I ran the same set of tests on a totally
> different network, with my xircom  realport ethernet card (tulip
> driver - 16bit) and from linux to linux and windows to linux. Scrolling
> through a message in mutt eventually slows down and if I lift my finger
> off the enter key whilst it's slow the scrolling keeps going, as if it
> was all bufferd. If I do a pingflood (ping -f) from a machine to my
> laptop it's all fine.
> 
> I am also now running 2.6.9-rc1-mm4.
> 

Have you tried FAQ:

echo 0 > /proc/sys/net/ipv4/tcp_window_scaling

- Arnaldo
