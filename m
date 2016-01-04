From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Mon, 4 Jan 2016 20:23:27 +0300
Message-ID: <568AAA8F.20403@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
 <5683D131.4090703@list.ru> <20160104010539.GC9087@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.mail.ru ([94.100.179.24]:44950 "EHLO smtp5.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688AbcADRNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:13:51 -0500
In-Reply-To: <20160104010539.GC9087@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

04.01.2016 04:05, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On (12/30/15 15:42), Stas Sergeev wrote:
>> 29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Do you have admin control over the ubuntu router?
>>> If yes, you might want to check the shared_media [#] setting
>>> on that router for the interfaces with overlapping subnets.
>>> (it is on by default, I would try turning it off).
>> That didn't help, problem re-appears.
> the code that sets things up for redirect is this:
I was also privately suggested that I could disable shared_media
insufficiently. Indeed, I've only done that for "all" (net.ipv4.conf.al=
l),
but not for the every particular IFace. So I'll re-try the test.
