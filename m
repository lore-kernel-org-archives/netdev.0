From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Sat, 17 Jan 2004 12:34:33 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401171234.33778.harisri@bigpond.com>
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
> *head scratch*

Sorry :-)

> Can you monitor 'vmstat 1' output on the r8169 host during the test ?

The computer deadlocks within few seconds (3 to 5), and it hangs everything 
including vmstat, and does not get as for as the file system. I will write it 
down by hand and post it.

Here is the sysrq-m when it hung, maybe this will provide some you wanted from 
vmstat:
SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu: empty

Free pages:      987624kB (0kB HighMem)
Active:2407 inactive:1605 dirty:1 writeback:0 unstable:0 free:246906
DMA free:13256kB min:12kB low:24kB high:36kB active:0kB inactive:0kB
Normal free:974368kB min:1004kB low:2008kB high:3012kB active:9628kB 
inactive:6420kB
HighMem free:0kB min:128kB low:256kB high:384kB active:0kB inactive:0kB
DMA: 0*4kB 1*8kB 0*16kB 2*32kB 2*64kB 2*128kB 2*256kB 0*512kB 0*1024kB 
0*2048kB 3*4096kB = 13256kB
Normal: 0*4kB 0*8kB 0*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 237*4096kB = 974368kB
HighMem: empty
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap:            0kB
262128 pages of RAM
5950 reserved pages
2977 pages shared
0 pages swap cached

> You can try 2.6.1-bk2 + Jeff Garzik's -netdev4 +
> http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch

I shall try this and then report the status.

> If it does not perform better, you can try against 2.6.1-bk1 the set at
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b

OK. I have tried 2.6.1-mm4 which includes the most recent -netdev updates from 
Jeff Garzik and it behaves the same way.

> If I remember correctly, you are the first report of a non-completely
> disfunctional driver for the new version of the r8169. Things improve.

Sorry I am unable to understand your statement.

Thanks
Hari
harisri@bigpond.com
