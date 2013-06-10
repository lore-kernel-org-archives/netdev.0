From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: net: fec: Enable imx6 enet checksum acceleration
Date: Mon, 10 Jun 2013 11:14:42 +0100
Message-ID: <51B5A712.5020502@mentor.com>
References: <CAFXsbZoz1wDS3LyZ+twLVnm-0=LDBmyhVB42=gNO+XurTk8pQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:49031 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab3FJKOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 06:14:45 -0400
In-Reply-To: <CAFXsbZoz1wDS3LyZ+twLVnm-0=LDBmyhVB42=gNO+XurTk8pQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

It is now only enabled for i.MX6q; Shawn Guo fixed it with the commit:
4849625569874d474ce351efd84b1f487ba08c94 net: fec: enable hardware
checksum only on imx6q-fec


Thank you,
Jim

On 09/06/13 03:30, Chris Healy wrote:
> Jim,
> 
> Can you tell me if the change you made to enable checksum acceleration
> works for other i.MX platforms?
> 
> I don't see anything in the code that differentiates between the various
> i.MX platforms with the Freescale FEC.
> 
> It seems to me that the i.MX28 and i.MX51 would also support this.
> 
> Was this patch tested with the other i.MX platforms that use this driver?
> 
> Chris
