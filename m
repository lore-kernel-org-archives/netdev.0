From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] net_dma: call dmaengine_get only if NET_DMA enabled
Date: Fri, 06 Feb 2009 23:03:11 -0700
Message-ID: <498D241F.4080005@intel.com>
References: <20090206.140912.40800913.davem@davemloft.net>	<e9c3a7c20902061452r40a97fa2p1fccfa78e3905458@mail.gmail.com>	<20090206.192910.42610645.davem@davemloft.net> <20090206.215533.166740686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "anemo@mba.ocn.ne.jp" <anemo@mba.ocn.ne.jp>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754559AbZBGGD0@vger.kernel.org>
In-Reply-To: <20090206.215533.166740686.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 06 Feb 2009 19:29:10 -0800 (PST)
> 
>> From: Dan Williams <dan.j.williams@intel.com>
>> Date: Fri, 6 Feb 2009 15:52:35 -0700
>>
>>> Yes, it has been on the todo list for a while, but I eventually want
>>> the net case to look more like the raid case.  I.e. have one code path
>>> that picks async versus sync at runtime, with the option to compile
>>> out async support with header file ifdefs only.
>> And how does any of that get us any closer to a fix right now
>> for this problem that doesn't require an ifdef?
>>
>> Someone please work on this.
> 
> I guess that'd end up being me....

Not necessarily, you did snap me back into reality with that comment.

> 
> How about something like this?

Looks good.

Thanks,
Dan
