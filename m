From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: page allocation failure
Date: Sun, 17 Oct 2004 12:39:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017103918.GA1517@electric-eye.fr.zoreil.com>
References: <200410162004.17573.jkillius@arcor.de> <200410162323.01006.jkillius@arcor.de> <20041016214903.GC21849@electric-eye.fr.zoreil.com> <200410170940.28350.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Killius <jkillius@arcor.de>
Content-Disposition: inline
In-Reply-To: <200410170940.28350.jkillius@arcor.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jan Killius <jkillius@arcor.de> :
[scp test]
> without TSO(1628MB  11.1MB/s   02:27):
>  1  0 166388  27716    332  97264    0    0 12300     0 12323  7616 37 45  0 18
>  1  0 166388  26108    332  99804    0    0 12880     4 12727  7975 39 52  0 9
>  1  0 166388  24612    336 102796    0    0 12720     0 12590  7900 38 48  0 15
[...]
> with TSO(1628MB  12.8MB/s   02:07):
>  1  0 166340  27672    376 120056    0    0 13740     0 11879  2041 36 58  6  0
>  1  0 166340  25352    384 122288    0    0 13968     4 12148  2072 41 55  3  1
>  1  0 166340  22924    376 124692    0    0 14028     0 12174  2050 36 60  4  0

It could be done again now that M. Xu fixed the issue but the numbers seem
consistent with the improvement I see here. TSO saves 5~8% of the cpu for
this kind of setup.

Thanks for the testing.

--
Ueimor
