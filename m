From: Julien BLACHE <jb@jblache.org>
Subject: Re: sky2 hangs
Date: Fri, 02 Feb 2007 11:44:55 +0100
Message-ID: <873b5o25zs.fsf@sonic.technologeek.org>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de>
	<42007.80.98.159.250.1170369983.squirrel@www.hunhost.com>
	<20070201145815.199bfe1a@freekitty>
	<20070202063104.GA13130@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Fagyal Csongor <concept@conceptonline.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sardaukar.technologeek.org ([213.41.134.240]:55145 "EHLO
	sonic.technologeek.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751952AbXBBLHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 06:07:36 -0500
In-Reply-To: <20070202063104.GA13130@cip.informatik.uni-erlangen.de> (Thomas
	Glanzmann's message of "Fri, 2 Feb 2007 07:31:04 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Glanzmann <thomas@glanzmann.de> wrote:

Hi,

>> I can reproduce the problem now (on mac mini). Interestingly it seems
>> to whack the whole ethernet switch when it happens.

I've observed that too, on a cheap DLink switch.

Next time sky2 hangs on me I'll try to reset the PHY and see if that
helps. I can usually trigger the hang by doing a couple of ifconfig
up/down on the interface, though I'm not getting any error message
from the driver when that happens.

JB.

-- 
Julien BLACHE                                   <http://www.jblache.org> 
<jb@jblache.org>                                  GPG KeyID 0xF5D65169
