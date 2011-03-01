From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Tue, 1 Mar 2011 12:04:21 -0800
Message-ID: <AANLkTimNfptGBzH0TeAZYvN1uEErd55aKBuvjPFggSSx@mail.gmail.com>
References: <loom.20110205T163216-459@post.gmane.org>
	<AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
	<loom.20110206T203347-475@post.gmane.org>
	<4D4FE100.5090808@gmail.com>
	<loom.20110214T141934-88@post.gmane.org>
	<AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com>
	<loom.20110226T011347-702@post.gmane.org>
	<AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com>
	<loom.20110226T120245-774@post.gmane.org>
	<AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com>
	<20110301101609.GA13261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chriss <mail_to_chriss@gmx.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56123 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab1CAUEW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 15:04:22 -0500
Received: by vws12 with SMTP id 12so4506138vws.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 12:04:21 -0800 (PST)
In-Reply-To: <20110301101609.GA13261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2011 at 2:16 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> Jesse Gross <jesse@nicira.com> :
> [...]
>> Putting a vlan device on eth1 actually affects the behavior of the
>> driver, which is why that works. =A0I suspect that if you put the vl=
an
>> device on both the physical interface and the bridge you would see
>> packets with tags on the bridge.
>>
>> Regardless, the solution is to remove the dependency on vlan devices
>> by converting over to the new vlan model. =A0Francois, any chance th=
at
>> you might have some time to look at this?
>
> The completely untested patch below is available for the (really) des=
perate
> souls.
>
> I should do a -next testing session this afternoon for this patch +
> Oliver's Neukum advertisement control + Hayes 8105e stuff (in reverse=
 order).

Thanks Francois.  When you are ready this looks good to me.

Reviewed-by: Jesse Gross <jesse@nicira.com>
