From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH net-next v2 00/10] be2net: patch set
Date: Wed, 30 Dec 2015 11:57:18 +0530
Message-ID: <CAKvpyk0X3ZncKWdz-a+Ek9XvC8brvJssKzwz+MQHNZv6c2MKPA@mail.gmail.com>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
	<20151229.155054.404543929028869618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35442 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbL3G1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 01:27:21 -0500
Received: by mail-yk0-f179.google.com with SMTP id x67so146745013ykd.2
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 22:27:20 -0800 (PST)
In-Reply-To: <20151229.155054.404543929028869618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 2:20 AM, David Miller <davem@davemloft.net> wrote:
>
> Please fix the problems reported by the kbuild test robot, they happened
> when I tried to build this too.

David, the test robot is complaining that all values of the enum are
not being handled by the switch statement.
There is a "return -EFAULT" after the switch statement that handles
all the other enum values. Anyway, I'm going to send a v3 adding a
default case to the switch to satisfy the compiler....thanks.
