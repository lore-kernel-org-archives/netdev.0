From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/8] dcbnl: Major simplifications
Date: Fri, 15 Jun 2012 20:53:23 -0700
Message-ID: <4FDC0333.5090806@intel.com>
References: <cover.1339591572.git.tgraf@suug.ch> <20120613.155541.26513304496438357.davem@davemloft.net> <20120614075435.GA29185@canuck.infradead.org> <4FDA0BFC.90807@intel.com> <20120615072659.GD29738@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, lucy.liu@intel.com
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14738 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906Ab2FPDx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 23:53:27 -0400
In-Reply-To: <20120615072659.GD29738@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/15/2012 12:26 AM, Thomas Graf wrote:
> On Thu, Jun 14, 2012 at 09:06:20AM -0700, John Fastabend wrote:
>> On 6/14/2012 12:54 AM, Thomas Graf wrote:
>>> On Wed, Jun 13, 2012 at 03:55:41PM -0700, David Miller wrote:
>>>> Lots of deleted code, I like it :-)
>>>>
>>>> Applied, but could you send a follow-on patch to use BUG_ON() instead
>>>> of that "if (!ptr) { /* ... */ BUG(); }" construct?
>>>
>>> Sure, I must have had a weak moment right there :)
>>>
>>
>> Nice! I'm a bit late but dumped this into my dcbnl netlink test kit
>> and everything looks good so...
>
> Thank you for testing John. Are you referring to lldp/test/nltest.c?
> I only discovered it after you mentioned a test kit. I've been feeding
> a list of commands through dcbtool for testing so far.
>

nltest works OK, I've got a variant here that I use to send/read
messages and also check the hardware registers on 82599. 'dcbtool'
works fine as well.

If I get some time I'll update nltest on open-lldp.

> BTW, I believe you mentioned at some point, that there is a patch
> available allowing non net_device based DCB users to use dcbnl.
> Otherwise I would start with the effort :)
>

Nope patch doesn't exist. I've been threatening to do it for awhile
now but haven't got to it. Yes please start it :)

I talked about it here once although it might be a bit out dated
now and I think if you have a lookup function then other things
besides scsci_hosts could be added easily,

http://www.linuxplumbersconf.org/2011/ocw/system/presentations/561/original/Plumbers2011.pdf

Thanks!
John
