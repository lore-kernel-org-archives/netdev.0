From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and
 whitespace cleanups
Date: Tue, 05 Jun 2012 14:38:14 -0700 (PDT)
Message-ID: <20120605.143814.549248889886122109.davem@davemloft.net>
References: <20120605.051437.1378262604943296071.davem@davemloft.net>
	<4FCDE447.3030103@computer.org>
	<4550590.BhQA539plh@flexo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.ceuleers@computer.org, b06378@freescale.com, joe@perches.com,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab2FEViP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 17:38:15 -0400
In-Reply-To: <4550590.BhQA539plh@flexo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 05 Jun 2012 12:54:34 +0200

> Hi,
> 
> On Tuesday 05 June 2012 12:49:43 Jan Ceuleers wrote:
>> On 06/05/2012 11:14 AM, David Miller wrote:
>> > From: Jan Ceuleers <jan.ceuleers@computer.org>
>> > Date: Tue, 05 Jun 2012 07:54:29 +0200
>> > 
>> >> So your build environment happens to be one of powerpc, alpha or mips,
>> >> does it?
>> > 
>> > No, I get those errors you posted too.
>> > 
>> > But like I said, you simply IGNORE THEM, and look for newly introduced
>> > errors and warnings.
>> 
>> David,
>> 
>> The error I quoted was a fatal error, meaning that compilation did not
>> proceed beyond the point to which the error pertained (inclusion of a
>> header that does not exist in my arch). So I cannot test-compile the
>> driver on my arch and draw any conclusions from that beyond line 91.
> 
> What about you setup a cross-compiler and build for one of these architectures 
> where the driver is enabled?

Dammit, people read what I'm saying.

This isn't even necessary for quick validation of patches.

You ignore the compile errors when you force build the driver, and
then you simply make sure you don't introduce any new errors of
warnings into the build.

For quick sanity checking a cross build is absolutely overkill and
simply not necessary.
