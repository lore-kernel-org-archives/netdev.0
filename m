From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: netconsole module cannot be removed
Date: Mon, 26 Feb 2007 16:40:57 -0500
Message-ID: <45E353E9.109@redhat.com>
References: <45E3447F.9080706@redhat.com> <20070226133156.3bfd2a74@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32988 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161219AbXBZVla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 16:41:30 -0500
In-Reply-To: <20070226133156.3bfd2a74@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 26 Feb 2007 15:35:11 -0500
> Chuck Ebbert <cebbert@redhat.com> wrote:
> 
>> Trying to remove netconsole, rmmod goes into a tight loop with
>> 100% CPU usage. It can't be killed with 'kill -9'. Shutdown
>> works, though. Kernel is 2.6.20 FC6 config, and I'm 99.9%
>> sure the module signing has nothing to do with this.
>>
> 
> No it probably has to do with printing a message during module removal.
> 

Yeah that could explain it.

But when I load it after the network has started I can't get it to
output any kernel messages to the network interface, either. I'll
try to reproduce this on a vanilla kernel next...

