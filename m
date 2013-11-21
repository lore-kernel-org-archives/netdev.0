From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Thu, 21 Nov 2013 15:23:09 -0800
Message-ID: <528E95DD.3060209@hp.com>
References: <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com> <20131119174323.GH913@1wt.eu> <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com> <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org> <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org> <20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu> <871u298lv6.fsf@natisbad.org> <20131121215259.GE18513@1wt.eu> <1385071201.10637.69.camel@edumazet-glaptop2.roam.corp.google.com> <87txf54b76.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:30407 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab3KUXXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 18:23:16 -0500
In-Reply-To: <87txf54b76.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 02:55 PM, Arnaud Ebalard wrote:
> On the RN2120, for a file served from /run/shm (for apache and nginx):
>
>            Apache     nginx       netperf
> 131072:  102 MB/s   112 MB/s   941.11 Mb/s
>   65536:  102 MB/s   112 MB/s   935.97 Mb/s
>   32768:  101 MB/s   105 MB/s   940.49 Mb/s
>   16384:   94 MB/s    90 MB/s   770.07 Mb/s
>    8192:   83 MB/s    66 MB/s   556.79 Mb/s

If you want to make the units common across all three tests, netperf 
accepts a global -f option to alter the output units.  If you add -f M 
netperf will then emit results in MB/s (M == 1048576).  I'm assuming of 
course that the MB/s of Apache and nginx are also M == 1048576.

happy benchmarking,

rick jones
