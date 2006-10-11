From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 7278] New: forcedeth slowed down by traffic shaping
Date: Wed, 11 Oct 2006 13:43:50 +0200
Message-ID: <20061011114350.GA3947@ff.dom.local>
References: <20061006172217.af619871.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-bugzilla@future.shiny.co.il,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44489 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932164AbWJKLjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 07:39:02 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061006172217.af619871.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07-10-2006 02:22, Andrew Morton wrote:
> On Fri, 6 Oct 2006 17:18:13 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=7278
>>
>>            Summary: forcedeth slowed down by traffic shaping
>>     Kernel Version: 2.6.16
>>             Status: NEW
>>           Severity: normal
>>              Owner: jgarzik@pobox.com
>>          Submitter: kernel-bugzilla@future.shiny.co.il
>>
>>
>> When assigninig a simple Tocket Bucket Filter (TBF) classless trafic shaping
>> policy to the eth0 device (provided by forcedeth), the device's upstream speed
>> drops to ~12kbyte/s, regardless of the traffic limit I set in the shaping rule.
>> In fact, the traffic limit values could be larger than the connection's
>> throughput and it'll still limit to mere 12kbyte/s. Once I revert the rule to
>> pfifo_fast, the rate resumes to the connection's real one (64kbyte/s).
>>
>> If I set the TBF lower than 96kbit on eth0, it indeed applies; in other words, I
>> can make the connection slower than 12kbyte/s but not faster.
>>
>> If I assign the same rule to ppp0, it works just as intended, for rules higher
>> than 12kbyte/s, leading me to believe forcedeth has something to do with it.
>>
>> (Is there any module parameter I can try tweaking?)

Isn't it to unpolite to expect from the submitter some details
like this tbf rule or testing with other kernel version?

Jarek P.  
