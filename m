From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 12:17:42 +0100
Message-ID: <52A99B56.1070503@redhat.com>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com> <20131211192138.GB4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab3LLLSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 06:18:22 -0500
In-Reply-To: <20131211192138.GB4675@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2013 08:21 PM, Hannes Frederic Sowa wrote:
> On Wed, Dec 11, 2013 at 12:45:14PM +0100, Denys Vlasenko wrote:
>> If ipv6 auto-configuration does not work, currently it's hard
>> to track what's going on. This change adds log messages
>> (at debug level) on every code path where ipv6 autoconf fails.
>>
>> v2: fixed indentation in multi-line log output statements.
> 
> Have you seen lots of those problems? Some of those seem like very
> serious problems and maybe could also deserve a pr_warn or pr_err.

I personally wasn't bitten by this problem, but our admins were.

They say that when they notice that ipv6 auconf didn't work
(i.e. they see no auconfigured addresses on the interfaces),
they usually see no useful messages in dmesg or /var/log/messages,
which makes them to try to fix the problem blind.

I can easily imagine their frustration. Kernel _knows_ why
it didn't work, and it's not expected to normally pappen,
why didn't it tell anything about it?

-- 
vda
