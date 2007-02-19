From: takada <takada@mbf.nifty.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Tue, 20 Feb 2007 08:56:39 +0900 (JST)
Message-ID: <20070220.085639.260788422.takada@mbf.nifty.com>
References: <20070217.231113.193678444.takada@mbf.nifty.com>
	<20070219145514.GO7582@csclub.uwaterloo.ca>
	<ada3b5253p0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lsorense@csclub.uwaterloo.ca, pcnet32@verizon.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965570AbXBSX6s@vger.kernel.org>
In-Reply-To: <ada3b5253p0.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Mon, 19 Feb 2007 11:48:27 -0800

>  > Does anyone know if there is any way to flush a cache line of the cpu to
>  > force rereading system memory for a given address or address range?
> 
> There is the "clflush" instruction, but not all x86 CPUs support it.
> You need to check the CPUID flag to know for sure (/proc/cpuinfo will
> show a "clflush" flag if it is supported).

/proc/cpuinfo with MediaGXm :

processor	: 0
vendor_id	: CyrixInstead
cpu family	: 5
model		: 5
model name	: Cyrix MediaGXtm MMXtm Enhanced
stepping	: 2
cpu MHz		: 199.750
cache size	: 16 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu tsc msr cx8 cmov mmx cxmmx
bogomips	: 401.00
clflush size	: 32
