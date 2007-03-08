From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8132] New: pptp server lockup in   ppp_asynctty_receive()
Date: Thu, 8 Mar 2007 09:45:39 +0100
Message-ID: <20070308084539.GA2423@ff.dom.local>
References: <20070305151331.3cdd98dd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, jura@netams.com,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51155 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030293AbXCHIlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 03:41:39 -0500
Content-Disposition: inline
In-Reply-To: <20070305151331.3cdd98dd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-03-2007 00:13, Andrew Morton wrote:
> On Mon, 5 Mar 2007 14:26:30 -0800
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=8132
>>
>>            Summary: pptp server lockup in ppp_asynctty_receive()
>>     Kernel Version:  2.6.20
>>             Status: NEW
>>           Severity: high
>>              Owner: jgarzik@pobox.com
>>          Submitter: jura@netams.com
>>                 CC: jura@netams.com
>>
>>
>> Already several kernel releases i've expirienced different lockups of  vpn 
>> (pptp) server.
>> There is more then 200  ppp connections sometimes.
>> With kernel debug i was able to retrive next information:

Could this be done with:
CONFIG_PROVE_LOCKING = y
CONFIG_4KSTACKS = n 

and, if possible, to send the first full lockdep error
message with some lines before it? It would be nice to
try to be more exact when hand writing, too.

Regards,
Jarek P.
