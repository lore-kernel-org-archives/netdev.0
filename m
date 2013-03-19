From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 23:19:39 +0900
Message-ID: <514873FB.5050202@hitachi.com>
References: <51486445.8040506@hitachi.com> <20130319133928.GE3137@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:46002 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005Ab3CSOTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:19:43 -0400
In-Reply-To: <20130319133928.GE3137@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

(2013/03/19 22:39), Ezequiel Garcia wrote:
> Hi Masami,
> 
> On Tue, Mar 19, 2013 at 10:12:37PM +0900, Masami Hiramatsu wrote:
>>
>> Here I've hit a bug on the recent kernel. As far as I know, this bug
>> exists on 3.9-rc1 too.
>>
>> When I tried the latest mvebu for-next tree
>> (git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
>> I got below warning at bootup time and mvneta didn't work (link was never up).
>> I ensured that "ifconfig ethX up" always caused that.
>>
>> Does anyone succeed to boot openblocks-ax3 recently or hit same
>> trouble?
> 
> This is a known bug. Gregory Clement already has a fix and he
> will submit it soon. In case you need this fixed ASAP, I'm attaching
> you a patch with a fix.

Thanks! I'll try that.

> Please note the attached patch is not ready for mainline inclusion,
> as I said Gregory will submit a cleaner version soon.

Yeah, I look forward to it :)

Thank you,

-- 
Masami HIRAMATSU
IT Management Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
