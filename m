From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] add the driver for Analog Devices Blackfin on-chip
 CAN controllers
Date: Fri, 11 Dec 2009 02:10:33 -0800 (PST)
Message-ID: <20091211.021033.211260458.davem@davemloft.net>
References: <1260524788-13103-1-git-send-email-21cnbao@gmail.com>
	<4B22183F.2070806@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 21cnbao@gmail.com, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	oe@port.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753942AbZLKKK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 05:10:27 -0500
In-Reply-To: <4B22183F.2070806@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Fri, 11 Dec 2009 11:00:31 +0100

> Barry Song wrote:
>> Signed-off-by: Barry Song <21cnbao@gmail.com>
>> Signed-off-by: H.J. Oertel <oe@port.de>
>> ---
>>  -v4:
>>  1. request and release interrupts in open/close instead of in module load/unload
>>  2. use bfin_read16/write16 instead of common readw/writew
>>  3. fix "line over 80 characters" checkpatch warning
>>  4. fix other coding style issues required by Wolfgang Grandegger
> 
> David, here is my
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.de>
> 
> for this driver. There is just some minor issue with the copyright
> below. IIRC, the merge window is still open.

The networking merge window is closed.  If I have to post a reference
to this announcement I made one more freakin' time I'm going to be
really angry:

http://marc.info/?l=linux-netdev&m=125988357131776&w=2

If people don't read the announcements I send to netdev, in particular
the ones I prefix with "README" to show it's important, I might as
well not do it at all.

Then you'll really have to guess what the current state of affairs
is :-)

But it doesn't even matter for this case because we can take
completely new drivers at any point in time, not just during
the merge window.
