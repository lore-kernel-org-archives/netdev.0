From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Fw: [Bug 65131] New: kernel panic (BUG_ON raised) in SCTP function
 sctp_cmd_interpreter
Date: Tue, 19 Nov 2013 00:49:19 +0100
Message-ID: <528AA77F.7010400@redhat.com>
References: <20131118091428.6360d82a@samsung-9> <528A5282.7090505@gmail.com> <528A6BFB.9050509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665Ab3KRXtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 18:49:25 -0500
In-Reply-To: <528A6BFB.9050509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2013 08:35 PM, Vlad Yasevich wrote:
> On 11/18/2013 12:46 PM, Vlad Yasevich wrote:

>> Should be fixed by:
>> commit 7926c1d5be0b7cbe5b8d5c788d7d39237e7b212c
>> Author: Daniel Borkmann <dborkman@redhat.com>
>> Date:   Thu Oct 31 09:13:32 2013 +0100
>>
>>      net: sctp: do not trigger BUG_ON in sctp_cmd_delete_tcb
>
> Just received confirmation that the above patch has been queued for 3.11.

Indeed, thanks !
