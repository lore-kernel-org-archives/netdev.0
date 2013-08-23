From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v2 5/5] ARM: dts: am33xx: adopt to cpsw changes
Date: Fri, 23 Aug 2013 14:08:37 +0200
Message-ID: <521750C5.3080209@gmail.com>
References: <1377247417-27386-1-git-send-email-zonque@gmail.com> <1377247417-27386-6-git-send-email-zonque@gmail.com> <52172B54.8020201@ti.com> <52172CB0.9030204@gmail.com> <52172E12.2000908@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:49765 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104Ab3HWMIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 08:08:42 -0400
In-Reply-To: <52172E12.2000908@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 11:40, Sekhar Nori wrote:
> On Friday 23 August 2013 03:04 PM, Daniel Mack wrote:
>> On 23.08.2013 11:28, Sekhar Nori wrote:

>> Ok, thanks. Given that this last patch will be merged through another
>> tree, can I just resend it separately, while David takes the rest as it is?
> 
> Ideally you could, but there are some bugs in the way compatible string
> in handled and due to this I suspect you need to reorder
> cpsw_of_mtable[] to match correctly. Not sure if the bug has been fixed
> in recent -rcs. Please check if modifying just this patch works and then
> go ahead and post.

No, you're right. I had to swap the two entries. Thanks for mentioning it.

> Please Cc Benoit Cousson <bcousson@baylibre.com> on your next submission
> as he is the one who picks up DT patches for OMAP.

Will do.



Daniel
