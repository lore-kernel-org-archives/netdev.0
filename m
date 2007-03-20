From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 18:45:21 -0700
Message-ID: <45FF3CB1.7080301@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <45FD619D.6030402@goop.org> <20070318170414.GB45869@muc.de> <45FD76E6.4060907@goop.org> <20070318193030.GB71548@muc.de> <45FDCF52.4000805@goop.org> <45FF3793.5050308@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	rusty@rustcorp.com.au, mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	anthony@codemonkey.ws, torvalds@linux-foundation.org,
	netdev@vger.kernel.org
To: Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:47613 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966070AbXCTBtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 21:49:53 -0400
In-Reply-To: <45FF3793.5050308@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zachary Amsden wrote:
> Jeremy Fitzhardinge wrote:
>>  If we then work out in each direction and see matched push/pops,
>> then we know what registers can be trashed in the call.  This also
>> allows us to determine the callsite size, and therefore how much space
>> we need for inlining.
>>   
>
> No, that is a very dangerous suggestion.  You absolutely *cannot* do
> this safely without explicitly marking the start EIP of this code. 
> You *must* use metadata to do that.  It is never safe to disassemble
> backwards or "rewind" EIP for x86 code. 

What do you mean the instruction before is "mov $0x52515000,%eax"?

Yeah, you're right.  Oh well.

    J
