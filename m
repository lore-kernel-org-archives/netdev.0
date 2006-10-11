From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 7278] New: forcedeth slowed down by traffic
 shaping
Date: Wed, 11 Oct 2006 13:51:23 +0200
Message-ID: <452CDABB.9050306@trash.net>
References: <20061011114350.GA3947@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	kernel-bugzilla@future.shiny.co.il,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:9630 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1161034AbWJKLt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 07:49:58 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061011114350.GA3947@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 07-10-2006 02:22, Andrew Morton wrote:
> 
>>On Fri, 6 Oct 2006 17:18:13 -0700
>>bugme-daemon@bugzilla.kernel.org wrote:
>>
>>
>>>http://bugzilla.kernel.org/show_bug.cgi?id=7278
>>>
>>>           Summary: forcedeth slowed down by traffic shaping
>>>    Kernel Version: 2.6.16
>>>            Status: NEW
>>>          Severity: normal
>>>             Owner: jgarzik@pobox.com
>>>         Submitter: kernel-bugzilla@future.shiny.co.il
>>>
>>>
>>>When assigninig a simple Tocket Bucket Filter (TBF) classless trafic shaping
>>>policy to the eth0 device (provided by forcedeth), the device's upstream speed
>>>drops to ~12kbyte/s, regardless of the traffic limit I set in the shaping rule.
>>>In fact, the traffic limit values could be larger than the connection's
>>>throughput and it'll still limit to mere 12kbyte/s. Once I revert the rule to
>>>pfifo_fast, the rate resumes to the connection's real one (64kbyte/s).
>>>
>>>If I set the TBF lower than 96kbit on eth0, it indeed applies; in other words, I
>>>can make the connection slower than 12kbyte/s but not faster.
>>>
>>>If I assign the same rule to ppp0, it works just as intended, for rules higher
>>>than 12kbyte/s, leading me to believe forcedeth has something to do with it.
>>>
>>>(Is there any module parameter I can try tweaking?)
> 
> 
> Isn't it to unpolite to expect from the submitter some details
> like this tbf rule or testing with other kernel version?


The TBF command would be a good start to make sure its not a
configuration error.

