From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: Fri, 8 Feb 2008 16:57:47 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802081656130.10726@bizon.gios.gov.pl>
References: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
 <871w7n34ss.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1369484947-1202486267=:10726"
Cc: Sven Wegener <sven.wegener@stealer.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:37497 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756706AbYBHP6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 10:58:31 -0500
In-Reply-To: <871w7n34ss.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1369484947-1202486267=:10726
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 8 Feb 2008, Andi Kleen wrote:

> Sven Wegener <sven.wegener@stealer.net> writes:
>
>> The default synchronization interval of 1000 milliseconds is too high fo=
r a
>> heavily loaded director. Collecting the connection information from one =
second
>> and then sending it out in a burst will overflow the socket buffer and l=
ead to
>> synchronization information being dropped. Make the interval controllabl=
e by a
>> sysctl variable so that users can tune it.
>
> It would be better if the defaults just worked under all circumstances.
> So why not just lower the default?
>
> Or the code could detect overflowing socket buffers and lower the
> value dynamically.

We can also start sending when amount of data reaches defined level.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1369484947-1202486267=:10726--
