From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Mon, 19 Jan 2004 22:51:41 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401192251.41323.harisri@bigpond.com>
References: <200401152039.00182.harisri@bigpond.com> <20040115220827.A22007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040115220827.A22007@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Friday 16 January 2004 08:08, Francois Romieu wrote:
> Can you monitor 'vmstat 1' output on the r8169 host during the test ?

Here it is (2.6.1-bk2-netdev4):
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 887000  10820  87992    0    0   291    47 1051   170  7  4 83  6

 0  0      0 886800  10820  87992    0    0     0   108 1042    13  0  0 100  
0
 0  0      0 886800  10820  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10820  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10820  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10836  87992    0    0     0    56 1013    18  0  0 100  
0
 0  0      0 886800  10840  87992    0    0     0     4 1009    10  0  0 100  
0
 0  0      0 886800  10840  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10840  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10840  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10848  87992    0    0     0    16 1011    11  0  0 100  
0
 0  0      0 886800  10848  87992    0    0     0     0 1008     7  0  0 100  
0
 0  0      0 886800  10848  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10848  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10848  87992    0    0     0     0 1008     3  0  0 100  
0
 0  0      0 886800  10856  87992    0    0     0    16 1011    11  0  0 100  
0
 0  0      0 886800  10864  87992    0    0     0   140 1037    12  0  0 100  
0
 0  0      0 886800  10864  87992    0    0     0     0 1008     3  0  0 100  
0
 2  0      0 886472  10864  87992    0    0     0     0 1305  1958 12 12 76  0

It hung at the final entry.

> You can try 2.6.1-bk2 + Jeff Garzik's -netdev4 +
> http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch

The r8169-tc-index-overflow.patch does not (cleanly) apply on 2.6.1-bk2 + 
netdev4.

> If it does not perform better, you can try against 2.6.1-bk1 the set at
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b

I am yet to try this combination.

Thanks
Hari
