From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Fri, 24 Apr 2009 16:49:14 +0200
Message-ID: <49F1D16A.8050003@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> 	<alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr> 	<49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com> 	<49F04F6B.7010709@trash.net> <beb91d720904230537s7f61c441g5af4a3acc1a0c2aa@mail.gmail.com> 	<49F061F2.9000005@trash.net> <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Salatiel Filho <salatiel.filho@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46701 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757796AbZDXOtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 10:49:21 -0400
In-Reply-To: <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salatiel Filho wrote:
> On Thu, Apr 23, 2009 at 09:41, Patrick McHardy <kaber@trash.net> wrote:
>> Salatiel Filho wrote:
>>> Using this actions would make  sfq hashing by dest ip or source ip
>>> work just like it works in imq ?
 >>>
>> Not with the SFQ default hash since it classifies based on the
>> addresses in the IP header. But you could use the flow classifier,
>> which can use the addresses from the conntrack entry. This would
>> behave similar to IMQ+SFQ.
 >>
> Ok , i was tying to keepthe discussion to the mainline kernel :)

The flow classifier is in the mainline kernel.

> By sfq i mean esfq [though i read somewhere sfq will implement a way
> to hash by src / dest ip] , or wrr :)
> Actually i was never able to find out why wrr is not in mainline
> kernel. In my opinion it is the best round robin qdisc i have ever
> used.

There is DRR since a couple of versions. Combined with the
flow classifier, it should provide the same functionality
as ESFQ.
