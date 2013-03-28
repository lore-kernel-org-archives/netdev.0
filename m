From: Yi Li <lovelylich@gmail.com>
Subject: Re: Difference between Net and Net-Next
Date: Thu, 28 Mar 2013 16:06:27 +0800
Message-ID: <5153FA03.6010005@gmail.com>
References: <loom.20130327T180118-245@post.gmane.org> <20130328062814.GC2511@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36196 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab3C1IGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 04:06:32 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so3974298pde.32
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 01:06:31 -0700 (PDT)
In-Reply-To: <20130328062814.GC2511@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8828=E6=97=A5 14:28, Richard Cochran =E5=
=86=99=E9=81=93:
> On Wed, Mar 27, 2013 at 05:02:28PM +0000, Jim Baxter wrote:
>> How do you decide which changes should go into "net" and which ones =
go into "net-
>> next"?
>>
>> At a guess I would think bug fixes are in "net" and feature changes =
into
>> "net-next" but it is not obvious from the commit log.
> I'll go out on a limb and try to explain this:
>
> net-next - changes for the next merge window
> net      - bug fixes and cleanups for the current release candidate
>
> HTR (hope thats right),
> Richard
>
net-next - new features added in development and *experimental*
net - features(thought as steady and come frome net-next tree) and bug=20
fixes, can be merged into linux.git(which is the tree below) by Linus.
linux - the mainline release.

That's my opinion.


regards,
Yi
