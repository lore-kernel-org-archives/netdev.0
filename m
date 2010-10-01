From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000 driver.
Date: Fri, 1 Oct 2010 14:50:52 +0100
Message-ID: <20101001135052.GA4209@srcf.ucam.org>
References: <20100928171026.GB6083@google.com> <4CA5E40D.4080507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elly Jones <ellyjones@google.com>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, jglasgow@google.com,
	msb@google.com, olofj@google.com
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:51239 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab0JANvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 09:51:01 -0400
Content-Disposition: inline
In-Reply-To: <4CA5E40D.4080507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 01, 2010 at 04:37:17PM +0300, Paulius Zaleckas wrote:
> On 09/28/2010 08:10 PM, Elly Jones wrote:
>> From: Elizabeth Jones<ellyjones@google.com>
>>
>> This driver is a rewrite of the original Qualcomm GPL driver, released as part
>> of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
>> Linux kernel style and made to use kernel APIs where appropriate; some bugs have
>> also been fixed. Note that the device in question requires firmware and a
>> firmware loader; the latter has been written by mjg (see
>> http://www.codon.org.uk/~mjg59/gobi_loader/).
>
> Why not use already existing in kernel firmware upload API?

Because chosing the correct firmware requires making a runtime policy 
decision, the firmware is of variable size (anywhere from 12MB to 16MB) 
and it needs to be reencoded with something resembling PPP framing 
before it gets dumped to the device. It's certainly possible to do it 
in-kernel, but it'd be rather a lot more code and allocating that much 
unswappable space sounds like something that would make some usecases 
impossible.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
