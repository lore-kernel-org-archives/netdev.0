From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 19 Jan 2005 19:50:07 -0600
Message-ID: <200501191950.08567.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501190903.45671.jeremy.guthrie@berbee.com> <16878.56487.600435.442912@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16878.56487.600435.442912@robur.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

@ 14:51:44 we can see the secret_interval kick in.  Otherwise we run very 
solid.  

101Kpps  8)

1024 buffers on the RX of eth3.

echo 86400 > /proc/sys/net/ipv4/route/secret_interval
echo 524288 > /proc/sys/net/ipv4/route/gc_thresh

It appears to be cruising right along now.

-----------

01/19/05 14:49:57 entries:  0007fffa  Pkts:  1413598  Err:  0  PPS:  94239  
Drop %:  0.0%  Eth3RXInt:  309669  Eth2TXInt:  36693
01/19/05 14:50:13 entries:  0007fff7  Pkts:  1448829  Err:  0  PPS:  96588  
Drop %:  0.0%  Eth3RXInt:  295522  Eth2TXInt:  36475
01/19/05 14:50:28 entries:  0007ffff  Pkts:  1449774  Err:  0  PPS:  96651  
Drop %:  0.0%  Eth3RXInt:  292556  Eth2TXInt:  36780
01/19/05 14:50:43 entries:  00080000  Pkts:  1454807  Err:  0  PPS:  96987  
Drop %:  0.0%  Eth3RXInt:  300945  Eth2TXInt:  35358
01/19/05 14:50:58 entries:  00080000  Pkts:  1426412  Err:  0  PPS:  95094  
Drop %:  0.0%  Eth3RXInt:  303005  Eth2TXInt:  35118
01/19/05 14:51:14 entries:  00080002  Pkts:  1471279  Err:  0  PPS:  98085  
Drop %:  0.0%  Eth3RXInt:  298152  Eth2TXInt:  35573
01/19/05 14:51:29 entries:  00080002  Pkts:  1402715  Err:  0  PPS:  93514  
Drop %:  0.0%  Eth3RXInt:  314880  Eth2TXInt:  37688
01/19/05 14:51:44 entries:  00007ef6  Pkts:  1335367  Err:  204660  PPS:  
89024  Drop %:  15.32%  Eth3RXInt:  203518  Eth2TXInt:  54907
01/19/05 14:52:00 entries:  00014a3a  Pkts:  1484009  Err:  0  PPS:  98933  
Drop %:  0.0%  Eth3RXInt:  138942  Eth2TXInt:  60283
01/19/05 14:52:15 entries:  0001f092  Pkts:  1441979  Err:  0  PPS:  96131  
Drop %:  0.0%  Eth3RXInt:  175142  Eth2TXInt:  53552
01/19/05 14:52:30 entries:  00028f95  Pkts:  1460829  Err:  0  PPS:  97388  
Drop %:  0.0%  Eth3RXInt:  181189  Eth2TXInt:  53574
01/19/05 14:52:45 entries:  000303a3  Pkts:  1423530  Err:  0  PPS:  94902  
Drop %:  0.0%  Eth3RXInt:  234029  Eth2TXInt:  48046
01/19/05 14:53:01 entries:  00035167  Pkts:  1443491  Err:  0  PPS:  96232  
Drop %:  0.0%  Eth3RXInt:  270393  Eth2TXInt:  40791
01/19/05 14:53:16 entries:  0003994a  Pkts:  1455118  Err:  0  PPS:  97007  
Drop %:  0.0%  Eth3RXInt:  276102  Eth2TXInt:  39695
01/19/05 14:53:31 entries:  0003df5a  Pkts:  1405048  Err:  0  PPS:  93669  
Drop %:  0.0%  Eth3RXInt:  287641  Eth2TXInt:  39903
01/19/05 14:53:46 entries:  00041f5c  Pkts:  1392438  Err:  0  PPS:  92829  
Drop %:  0.0%  Eth3RXInt:  307840  Eth2TXInt:  40216
01/19/05 14:54:01 entries:  00045da3  Pkts:  1486506  Err:  0  PPS:  99100  
Drop %:  0.0%  Eth3RXInt:  280067  Eth2TXInt:  38030
01/19/05 14:54:17 entries:  00049a78  Pkts:  1504340  Err:  0  PPS:  100289  
Drop %:  0.0%  Eth3RXInt:  276769  Eth2TXInt:  36982
01/19/05 14:54:32 entries:  0004d72b  Pkts:  1489358  Err:  0  PPS:  99290  
Drop %:  0.0%  Eth3RXInt:  280576  Eth2TXInt:  37378
01/19/05 14:54:47 entries:  00051214  Pkts:  1475776  Err:  0  PPS:  98385  
Drop %:  0.0%  Eth3RXInt:  289098  Eth2TXInt:  36632
01/19/05 14:55:02 entries:  00054ceb  Pkts:  1527761  Err:  0  PPS:  101850  
Drop %:  0.0%  Eth3RXInt:  273478  Eth2TXInt:  35447
01/19/05 14:55:18 entries:  000584f7  Pkts:  1482312  Err:  0  PPS:  98820  
Drop %:  0.0%  Eth3RXInt:  288181  Eth2TXInt:  35792
01/19/05 14:55:33 entries:  0005be56  Pkts:  1477823  Err:  0  PPS:  98521  
Drop %:  0.0%  Eth3RXInt:  284099  Eth2TXInt:  36698
01/19/05 14:55:48 entries:  0005f55b  Pkts:  1489107  Err:  0  PPS:  99273  
Drop %:  0.0%  Eth3RXInt:  289669  Eth2TXInt:  36162
01/19/05 14:56:03 entries:  00062ae8  Pkts:  1451832  Err:  0  PPS:  96788  
Drop %:  0.0%  Eth3RXInt:  299549  Eth2TXInt:  36259
01/19/05 14:56:19 entries:  000660cd  Pkts:  1423292  Err:  0  PPS:  94886  
Drop %:  0.0%  Eth3RXInt:  306119  Eth2TXInt:  36382
01/19/05 14:56:34 entries:  000697a1  Pkts:  1458930  Err:  0  PPS:  97262  
Drop %:  0.0%  Eth3RXInt:  302765  Eth2TXInt:  37878


On Wednesday 19 January 2005 04:18 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  gc_elasticity, gc_interval, gc_thresh etc I would avoid
>  > > gc_min_interval.
>  >
>  > I have done a little tweaking. I now hold at around 520K routes in the
>  > hash. I still drop packets every secret_interval but I've upped that
>  > counter so I don't whack all of my hash entries all that often.
>
>  Sounds you done progress.
>  This with relative conservative setting if RX-buffers?
>
>  secret_interval needs special care as it flushes the cache totally.
>
>  What did you tweak?
>  Your output from rtstat will be very interesting.
>
>
>       --ro

-- 

--------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711
