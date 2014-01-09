From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] net: make tcp_cleanup_rbuf private
Date: Thu, 09 Jan 2014 15:42:32 -0500 (EST)
Message-ID: <20140109.154232.65818281679170677.davem@davemloft.net>
References: <20140109201642.28381.82141.stgit@viggo.jf.intel.com>
	<CADVnQy=Tk68y217cbw7O5apCJV+eOmKMqLNbgAZRa_cxUArdKg@mail.gmail.com>
	<CAPcyv4hPnCud=MWpsCMNZmK_BwVV8WZHOs7=GQMhymgkv-gNkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, dmaengine@vger.kernel.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, jmorris@namei.org,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, linux-kernel@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaAIUmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:42:35 -0500
In-Reply-To: <CAPcyv4hPnCud=MWpsCMNZmK_BwVV8WZHOs7=GQMhymgkv-gNkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Jan 2014 12:33:29 -0800

> On Thu, Jan 9, 2014 at 12:26 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Thu, Jan 9, 2014 at 3:16 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>>> net_dma was the only external user so this can become local to tcp.c
>>> again.
>> ...
>>> -void tcp_cleanup_rbuf(struct sock *sk, int copied)
>>> +static void cleanup_rbuf(struct sock *sk, int copied)
>>
>> I would vote to keep the tcp_ prefix. In the TCP code base that is the
>> more common idiom, even for internal/static TCP functions, and
>> personally I find it easier to read and work with in stack traces,
>> etc. My 2 cents.
>>
> 
> Ok.  It was cleanup_rbuf() in a former life, but one vote for leaving
> the name as is is enough for me.

You can make that two votes :)
