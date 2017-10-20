From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Problems with mvneta
Date: Fri, 20 Oct 2017 09:09:56 +0200
Message-ID: <20171020090956.2b6cc34b@windsurf.home>
References: <20171018223425.42ce7a74@gmx.de>
        <20171018225557.43837338@windsurf.home>
        <20171020002524.4b4cf122@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: =?UTF-8?B?R3LDqWdvcnk=?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?UTF-8?B?VMOpbmFydA==?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Sven =?UTF-8?B?TcO8bGxlcg==?= <musv@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:39635 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdJTHKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 03:10:07 -0400
In-Reply-To: <20171020002524.4b4cf122@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, 20 Oct 2017 00:25:24 +0200, Sven Müller wrote:

> First of all I'm not familiar with kernel programming at all, so
> please excuse me, if I don't understand everything at the first
> glance. 

No problem. Your bug report and effort to nail down the issue are much
appreciated!

> It compiles and runs fine. After a couple of hours and testing no
> issues were found. 

OK, so this really hints at a regression in the mvneta driver itself.

Could you try to revert just:

  6ad20165d376fa07919a70e4f43dfae564601829
  a29b6235560a1ed10c8e1a73bfc616a66b802b90
  2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a

first all of them, and then each one by one, so that we can pin-point
the commit that causes the breakage ?

I looked at all the other changes in mvneta between 4.10 and 4.12, and
I don't see how any of the other changes can cause a functional
difference. So let's focus on those 3 commits for the moment.

Assuming you're using Git, to revert a commit just do: "git revert
<commitid>".

Thanks again!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
