From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 12:10:44 +0200
Message-ID: <b2cc26e40910210310o31ca24dcv50f8bd0c3234b71b@mail.gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	 <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>
	 <4ADEB752.50103@gmail.com>
	 <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>
	 <4ADED186.3040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:55361 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbZJUKKj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 06:10:39 -0400
Received: by yxe17 with SMTP id 17so5868008yxe.33
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 03:10:44 -0700 (PDT)
In-Reply-To: <4ADED186.3040300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2009 at 11:16 AM, William Allen Simpson
<william.allen.simpson@gmail.com> wrote:
> Keep in mind that I'm busy trying to replace syncookies with real coo=
kies,
> so I'm biased. =C2=A0The syncookies interfere with new options; altho=
ugh in
> Linux, they interfere less than other systems.

How and when do they interfere?
If syn cookies are enabled and the queue isn't full, they're not used
so they don't interfere.
If the queue is full, they do interfere, but the alternative would be
no connection at all.
So I really don't see the disadvantage of enabling cookies by default.

> As Ubuntu is debian based, perhaps they can back-port the Ubuntu chan=
ges?

Actually changing the value isn't the problem, but the Debian
maintainer isn't sure it's a good idea (but he doesn't know why).

Olaf
