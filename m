From: Jan Killius <jkillius@arcor.de>
Subject: Re: r8169: page allocation failure
Date: Sun, 17 Oct 2004 09:40:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410170940.28350.jkillius@arcor.de>
References: <200410162004.17573.jkillius@arcor.de> <200410162323.01006.jkillius@arcor.de> <20041016214903.GC21849@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041016214903.GC21849@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 16 October 2004 23:49, Francois Romieu wrote:
> Jan Killius <jkillius@arcor.de> :
> > On Saturday 16 October 2004 23:04, Jan Killius wrote:
> > > > - what is the current transfer rate and is it better/worse w/o TSO ?
> > >
> > > I'm getting almost the same with both settings ~405Mbit/s.
>
> Roughly the same CPU usage ?
I have tested the maximum transfer rate with netperf here makes TSO no 
difference in cpu usage.
>
> > > > - which cpu/disk system are there within the (?) 128Mo box ?
> > >
> > > Athlon XP 1600+ the disk is a Maxtor 6Y060L0 gets with hdparm 42.76
> > > MB/s
> >
> > ups forget to say the ram size 512MB FSB333 DDR RAM
>
> I did not notice it first but the bi/bo columns of the vmstat output
> are mostly null. Assuming this is a single session ftp transfer, what ftp
> software does the r8169 based system run ?
vsftpd
>
> Pure curiosity: can you issue a test+vmstat with a blowfish scp to see if
> TSO makes a difference for your setup when the system is not disk-limited ?
without TSO(1628MB  11.1MB/s   02:27):
 1  0 166388  27716    332  97264    0    0 12300     0 12323  7616 37 45  0 
18
 1  0 166388  26108    332  99804    0    0 12880     4 12727  7975 39 52  0 9
 1  0 166388  24612    336 102796    0    0 12720     0 12590  7900 38 48  0 
15
 1  0 166388  27644    332 100420    0    0  8232     0 8845  5517 27 30  2 40
 1  2 166388  27648    368 101024    0    0 11240     4 11705  7546 35 44  0 
21
 1  0 166388  26592    384 102536    0    0 12372    56 13001  8409 34 55  0 
11
 1  2 166388  25192    388 104424    0    0 12504     0 12428  7700 43 44  0 
13
 1  0 166388  25488    436 104424    0    0 10844    48 10900  6868 34 40  0 
27
 0  1 166388  25076    452 105200    0    0 11928     0 11949  7412 36 48  0 
17
 1  1 166388  24412    456 106108    0    0 12172    60 12225  7612 39 45  0 
15
with TSO(1628MB  12.8MB/s   02:07):
 1  0 166340  27672    376 120056    0    0 13740     0 11879  2041 36 58  6  
0
 1  0 166340  25352    384 122288    0    0 13968     4 12148  2072 41 55  3  
1
 1  0 166340  22924    376 124692    0    0 14028     0 12174  2050 36 60  4  
0
 1  0 166340  20896    368 126696    0    0 13644     0 11859  2016 39 54  7  
0
 0  0 166340  30792    352 116856    0    0 13328     0 11646  2013 36 56  8  
0
 1  0 166340  28440    332 119280    0    0 14156     0 12343  2063 37 59  2  
2
 1  3 166340  28120    348 119556    0    0 11936     4 10527  2329 32 49  4 
15
 1  3 166340  27728    456 119920    0    0 12152     4 10549  2516 31 52  0 
17
 2  0 166340  26600    492 120588    0    0 12216   208 10347  2274 37 48  0 
16
 0  2 166340  24344    572 122760    0    0 13900     0 11937  2217 37 58  0  
5

>
> --
> Ueimor

-- 
        Jan
