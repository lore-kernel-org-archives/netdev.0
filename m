From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Sun, 09 Sep 2007 23:31:47 -0700
Message-ID: <46E4E4D3.7040905@intel.com>
References: <46E0FB82.2040000@gmail.com> <46E3C3B9.4010500@gmail.com> <46E478BE.2030202@intel.com> <46E4E305.6010406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39361 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbXIJGbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 02:31:49 -0400
In-Reply-To: <46E4E305.6010406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> Kok, Auke napsal(a):
>> Jiri Slaby wrote:
>>> I still have problems with the driver. When I do `ip link set eth0
>>> up', ksoftirq
>>> runs with 100 % cpu time, so I think you endlessly re-schedule some
>>> timer (or
>>> the new napi layer?)
>> something changed in the logic and e1000e apparently does something
>> wrong. I'll look into it on monday and resubmit a fixup patch (see
>> robert olsson's mail as well discussing this issue)
> 
> he's posted me a patch, but no change on my side :(.

that's what I feared/thought as well when I saw his patch - e1000e and e1000 are 
slightly different so the exit condition will be as well.

> Anyway, I'm going away of the box on monday (today). will be back on fri to
> test patches :).

I'll be on top of it. Since e1000e will be merged I need to get this workign 
properly before the merge window opens - no pressure :)

Auke
