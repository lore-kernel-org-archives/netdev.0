From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH 1/2] drivers/net/usb/qcusbnet: Checkpatch cleanups
Date: Fri, 1 Oct 2010 16:54:28 +0300
Message-ID: <AANLkTinHA2_XGysae7Fj+r=dshnbfZ=mvDFzCAzZQ75i@mail.gmail.com>
References: <20100928171026.GB6083@google.com>
	<cover.1285727642.git.joe@perches.com>
	<0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
	<4CA5E185.3090902@gmail.com>
	<1285940519.752.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Elly Jones <ellyjones@google.com>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35062 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab0JANya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 09:54:30 -0400
Received: by wyb28 with SMTP id 28so2926263wyb.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 06:54:29 -0700 (PDT)
In-Reply-To: <1285940519.752.10.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 1, 2010 at 4:41 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2010-10-01 at 16:26 +0300, Paulius Zaleckas wrote:
>> On 09/29/2010 05:39 AM, Joe Perches wrote:
>> > Whitespace and removal of KERNEL_VERSION tests
>> > Neaten DBG macro
>>
>> Why not use dev_dbg istead of this ugly DBG macro?
>
> Currently, like a lot of other macros
> in the tree, it uses a runtime flag to
> control output.
>
> dev_dbg doesn't have that capability.

It has runtime flag if CONFIG_DYNAMIC_DEBUG is enabled.
