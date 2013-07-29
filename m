From: "Artem S. Tashkinov" <t.artem@lycos.com>
Subject: Re: A call to revise sockets behaviour
Date: Mon, 29 Jul 2013 17:31:56 +0000 (UTC)
Message-ID: <144572220.42656.1375119116406.JavaMail.mail@webmail09>
References: <2066879158.39771.1375110634453.JavaMail.mail@webmail09><20130729083519.5d574f16@nehalam.linuxnetplumber.net>
 <2063167407.40450.1375112877907.JavaMail.mail@webmail09><51F6A5E2.5050100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0046.b.hostedemail.com ([64.98.42.46]:58121 "EHLO
	smtprelay.b.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758325Ab3G2RcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 13:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jul 29, 2013 11:27:00 PM, rick wrote:

>> A wine developer clearly showed that this option simply doesn't work.
>>
>> http://bugs.winehq.org/show_bug.cgi?id=26031#c21
>>
>> Output of strace:
>> getsockopt(24, SOL_SOCKET, SO_REUSEADDR, [0], [4]) = 0
>> setsockopt(24, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>> bind(24, {sa_family=AF_INET, sin_port=htons(43012), sin_addr=inet_addr("0.
>> 0.0.0")}, 16) = -1 EADDRINUSE (Address already in use)
>
>The output of netstat -an didn't by any chance happen to still show an 
>endpoint in the LISTEN state for that port number did it?
>
>rick jones
>


By chance - no, nothing is/was listening. You can recreate this test in an order of few
minutes without ever trusting my word.
