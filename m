From: Christopher Chan <cchan@outblaze.com>
Subject: network unavailable with 2.6.4 (2)
Date: Wed, 31 Mar 2004 13:52:56 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406A5CB8.9060802@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After waiting for a bit, network connectivity is restored...

and I got the following from the logs...

Mar 31 05:45:10 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 31 05:45:10 spf6 kernel: recvmsg bug: copied 56144D09 seq 56144D21
Mar 31 05:45:10 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 31 05:45:10 spf6 kernel: recvmsg bug: copied C1BC15E2 seq C1BC15FE
Mar 31 05:45:10 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 31 05:45:10 spf6 kernel: recvmsg bug: copied A2E73B39 seq A2E73B55
Mar 31 05:45:10 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 31 05:45:10 spf6 kernel: recvmsg bug: copied B11E6A67 seq B11E6A6D
Mar 31 05:45:10 spf6 kernel: KERNEL: assertion (!skb || 
before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq)) failed at 
net/ipv4/tcp.c (1326)

at the same time, serial console was messed up during the period of 
'blackout'

we had stuff look the following being dumped...

cpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.EEep.(f/i& tpised  (er 
aN<3RUp-3>_ ( |se(1gs4/S>c4/io naio n: ait  ai3>UN->>_P(1| 
eq15s4/SGco/tonnagonne ail  ail>KNC>>KPE16 Mq 5s /tG_optcnnegsn etail 
|asleKNC>rKEEE63Mq 57 &tc_optcn etsn etasle||sleKEC)rcERE63MS 
=71&tc_Ppicp (ts  (t/sse||ssedER))cEREK35SG=71& cpPEicp (t/ &(t/ised| 
sed RN)cvRNK)5)G==1) Mp.Eiep.(f/i& t/ised  (ed RN))vRNK)5)G_= ) 
Mp.EEed.(f/i& tpiped  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& t/ised  (er 
RN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  (er aN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised| sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& t/ised  (er 
RN))v_NE)5)G_= )
Mp.Eiep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.Eiep.(f/i& t/ised  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))vRNK)5)G_=1) Mp.EEep.(f/i& t/ised  (er 
RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
aN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep.(f/ &(t/ised| sed R))cvRNK)5)G==1) MpPEiep.(f/i&(t/ised  sed 
RN))v_NK)5)G_=1) Mp.EEed.(f/i& tpiped  (er aNE)v_NE)
)
==1) Mp.EEep.(f/i& t/ised  (er RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )
_=1) Mp.EEep.(f/i& t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised 
(er RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiped  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i& tpised  (er aN))v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEed.(f/i& tpised  (er 
aN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aNE)v_NE) )
==1) Mp.EEep.(f/i& tpiped  (er aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(fli& tpiper a(er 
aNE) _nE) )
_= ) Mp.EEed.cf/i& tpiped  (er aN))v_NE) )G_= )
Mp.EEep.(f/i& tpised  (er RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.cflip tpiper a(er 
aNE) _NE) )
_= ) Mp.EEed.(f/i& tpiped  (er aNE)v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiper  (er 
aNE) _NE) )
==1) Mp.EEed.(f/i& tpised  (er RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised 
(er RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed R))cvRNK)5)G==1) Mp.Eiep.(f/i& tpised  (ed 
RN))v_NE)5)G_= )
cpPEiep.(f/i&(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))vRNK)5)G_=1) Mp.EEep.(f/i& tpised  (er 
aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aNE) _NE) )
_= ) Mp.EEep.(f/i& tpiped  (er aNE)v_NE) )
_=1) Mp.EEep.(f/i& tpised  (er aN))v_NE) )
==1) Mp.EEed.(f/i& tpised  (er RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  (ed RN))v_NK)5)G_=1) Mp.EEed.cf/i& tpiper  (er 
aN))v_NE) )
==1) Mp.EEed.(f/i& tpiped  (er aNE)v_NE) )
==1) Mp.EEed.(f/i& tpised  (er RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/i&(t/ised| sed RN))vRNK)5)G_= ) Mp.EEep.(f/i& tpised  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.Eiep.(f/i& t/ised  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aNE)v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/i&(t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  (ed RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (er RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i& t/ised  (er RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiper 
(er aNE)v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised 
(er aN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& tpised  (ed 
RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised| sed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiper  (er 
aNE) _NE) )
_=1) Mp.EEed.(f/i& t/ised  (er RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (er RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEep.(f/i& tpised  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (er RN))v_NE) )G_= )
Mp.Eiep.(f/i& tpised  (er RN))v_NE)5)G_= )
MpPEiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep (t/ &(t/ssed| sedER))cvRNK)5SG==1) MpPEiep.(f/i&(t/ised  (ed 
RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er aN))v_NE)
)
==1) Mp.Eiep.(f/i& t/ised  (er aN))v_NE) )
==1) MpPEiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& tpiped  (er 
aNE)v_NE) )
_=1) Mp.EEed.(f/i& tpised  (er aN))v_NE) )
_=1) Mp.EEep.(f/i& tpised  (er aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEep.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i& t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.EEep.(f/i& tpised  (er 
RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiper a(er aNE) _NE)
)
_=1) Mp.EEep.(f/i& tpised  (er aN))v_NE) )
_=1) Mp.EEed.cf/i& tpiped  (er aNE)v_NE) )
_=1) Mp.EEed.(f/i& tpised  (er aN))v_NE) )
==1) Mp.EEep.(f/i& t/ised  (er RN))v_NE)5)G_= )
MpPEiep.(f/i&(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (er RN))v_NE) )
==1) Mp.EEep.(f/i& t/ised  (er RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& tpiped  (er 
aN)) _nEL )
_= )
cpPEiep.(f/i&(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aNE) _NE) )
_=1) Mp.EEed.(f/i& tpised  (er aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  (ed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiper  (er 
aNE)v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEep.(f/i& tpiped  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (er RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
aN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i& t/ised  (er aN))v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  (er RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (er RN))v_NE) )
==1) Mp.Eiep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_=1) Mp.EEep.(f/i& tpised  (er 
aN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_=1) Mp.EEed.cf/i& tpiped  (er 
aNE)v_NE) )
_=1) Mp.Eiep.(f/i& t/ised  (er RN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed RN))vRNK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))vRNK)5)G_=1) Mp.EEep.(f/i& tpised  (er 
RN))v_NE)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEep.(f/i& t/ised  (ed 
RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpised  (er 
aNE)v_NE) )
_=1) Mp.EEep.(f/i& tpised  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiper  (er 
aNE)v_NE) )
_=1) Mp.EEed.cf/i& tpiper  (er aN))v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  (er RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_=1) Mp.EEed.(f/i& t/ised  (ed 
RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised  sed RN))v_NK)5)G_=1) Mp.EEep.(f/i& tpised  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed R))cvRNK)5)G_=1) Mp.EEed.(f/i& tpised  (er 
RN))v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )G_= )
MpPEiep.(f/i& t/ised  sed RN))v_NK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )
==1) Mp.EEep.(f/i& tpised  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.EEep.(f/i& t/ised  (er 
RN))v_NE) )G_= )
MpPEiep.(f/i& t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEep.(f/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (ed RN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G_= )
cpPEiep.(t/ &(t/ised  (ed RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (er RN))v_NE)5)G_= )
MpPEiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= )
cpPEiep (t/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.EEep.(f/i& t/ised  (er 
RN))v_NE)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))vRNK)5)G_= ) Mp.EEed.(f/i& tpiped  (er 
aN))v_NE) )G_= )
Mp.EEep.(f/i& t/ised  (ed RN))v_NE)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed R))cvRNK)5SG==1) Mp.Eiep.(f/i& t/ised  (er 
aN))v_NE) )
==1) Mp.Eiep.(f/i& t/ised  (er RN))v_NE) )G_= )
Mp.Eiep.(f/i& tpised  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i&(t/ised  sed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)cvRNK)5)G_=1) Mp.EEep.(f/i& tpiped  (er 
RN))v_NE) )G_= )
Mp.Eiep.(f/i& t/ised  (er aN))v_NE) )G_= )
Mp.Eiep.(f/i& tpised  (er aN))v_NE) )G_= )
MpPEiep.(f/ &(t/ised| sed RN))vRNK)5)G==1) Mp.Eiep.(f/i& t/ised  (ed 
RN))v_NE)5)G_= )
MpPEiep.(f/ &(t/ised| sed RN)cvRNK)5)G==1) Mp.EEep.(f/i& tpised  (er 
RN))v_NE)5)G_= )
cpPEiep.(f/ &(t/ised  sed RN))vRNK)5)G_= ) Mp.EEed.cf/i& tpiper  (er 
aNE)v_NE) )
==1) Mp.EEep.(f/i& t/ised  (ed RN))v_NK)5)G_= ) Mp.EEed.cf/i& tpiper 
(er aNE) _NE) )
_=1) Mp.EEed.cf/i& tpiped  (er aNE) _NE) )
_= ) Mp.EEed.(f/i& tpiped  (er aNE) _NE) )
==1) Mp.Eiep.(f/i& t/ised  (er RN))v_NE) )G_= )
MpPEiep.(f/i&(t/ised  (ed RN))v_NK)5)G_= )
cpPEiep.(t/ &(t/ised| sed RN)) failed at net/ipv4/tcp.c (1635)


after the blackout, output returns to normal
