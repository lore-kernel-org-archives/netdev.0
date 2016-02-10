From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Scaling the Number of Network Interfaces on Linux
Date: Wed, 10 Feb 2016 16:12:45 +0100
Message-ID: <56BB536D.9040802@6wind.com>
References: <56BB1BEB.5090200@6wind.com>
 <56BB2634.3080500@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37794 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbcBJPMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 10:12:49 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so30968413wme.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 07:12:48 -0800 (PST)
In-Reply-To: <56BB2634.3080500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/02/2016 12:59, David Ahern a =C3=A9crit :
> On 2/10/16 12:15 PM, Nicolas Dichtel wrote:
[snip]
>> Instead of removing completly the sysctl entries, another idea could=
 be to
>> manage a group of interfaces which will share the same subtree.
>
> This come out from a side conversation as well -- for example to have=
 interfaces
> enslaved to a bridge or bond share the same devconf.
It could also be interesting to have another way to group interfaces. F=
or
example, group all ppp interfaces.

>
> This is certainly possible to do and I can give it a look. The key po=
int is that
> we clearly need a means to lighten the overhead of a network interfac=
e.
Yes, I agree.
