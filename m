From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Linux 4.2.4
Date: Mon, 26 Oct 2015 10:11:11 +0100
Message-ID: <562DEE2F.6030809@wiesinger.com>
References: <20151023003306.GA25388@kroah.com>
 <562C83FD.6010402@wiesinger.com> <20151025082547.GA22300@kroah.com>
 <20151025090308.GA17656@1wt.eu> <562CA13C.90500@wiesinger.com>
 <20151025094634.GA6832@1wt.eu> <562CB396.2080509@wiesinger.com>
 <alpine.DEB.2.10.1510252032420.14141@blackhole.kfki.hu>
 <562D36D9.9060504@wiesinger.com>
 <alpine.DEB.2.10.1510260945510.17014@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@vger.kernel.org, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1510260945510.17014@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26.10.2015 09:58, Jozsef Kadlecsik wrote:
> On Sun, 25 Oct 2015, Gerhard Wiesinger wrote:
>
>> Also any idea regarding the second isssue? Or do you think it has the
>> same root cause?
> Looking at your RedHat bugzilla report, the "nf_conntrack: table full,
> dropping packet" and "Alignment trap: not handling instruction" are two
> unrelated issues and the second one is triggered by the unaligned counter
> extension acccess in ipset, I'm investigating. I can't think of any reason
> how those issues could be related to each other.

Yes, they are unrelated.
Issue 1: nf_conntrack: table full, dropping packet => Fixed with 4.2.4
Issue 2: Alignment trap: not handling instruction => Happens when ipset 
counters are enabled

Please keep in mind it happens with IPv6 commands.

Currently 4.2.4 without ipset counters runs well.

Ciao,
Gerhard
