From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 20:45:03 +0200
Message-ID: <b2cc26e40910211145x59a60439m427fc83ff9d76a80@mail.gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	 <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>
	 <4ADEB752.50103@gmail.com>
	 <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>
	 <4ADED186.3040300@gmail.com>
	 <b2cc26e40910210310o31ca24dcv50f8bd0c3234b71b@mail.gmail.com>
	 <4ADF5499.2080107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f216.google.com ([209.85.217.216]:48743 "EHLO
	mail-gx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715AbZJUSpB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 14:45:01 -0400
Received: by gxk8 with SMTP id 8so7715766gxk.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 11:45:05 -0700 (PDT)
In-Reply-To: <4ADF5499.2080107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2009 at 8:36 PM, William Allen Simpson
<william.allen.simpson@gmail.com> wrote:
> Olaf van der Spek wrote:
>>
>> How and when do they interfere?
>> If syn cookies are enabled and the queue isn't full, they're not use=
d
>> so they don't interfere.
>> If the queue is full, they do interfere, but the alternative would b=
e
>> no connection at all.
>
> You just answered your own question, both "how" and "when"....

No, I didn't.

>> So I really don't see the disadvantage of enabling cookies by defaul=
t.
>>
> On systems with long delay paths, it represents turning back the cloc=
k
> more than a decade or so.

How's that? Are you saying no connection is better than a connection
with timestamps and SACK?
I don't believe you.

Wasn't there recently a patch to enable these things even when syn
cookies are actually being used?

> A better solution is usually a firewall/IDS.

Why's that?

> The best solution: I'm working on it.

Hmm, got any link to those cookies? I can only find docs on SYN cookies=
=2E

> As I'm sure you're aware, Timestamps and Sack options are fairly cruc=
ial.

Of course. I'm not saying you should disable them.

>
>>> As Ubuntu is debian based, perhaps they can back-port the Ubuntu ch=
anges?
>>
>> Actually changing the value isn't the problem, but the Debian
>> maintainer isn't sure it's a good idea (but he doesn't know why).
>>
> Well, that depends. =C2=A0For a client, it's a good idea, as the defe=
nse is
> mostly local and rare. =C2=A0For a server run by a small underfunded =
ISP, it's
> still a good idea as a last ditch defense. =C2=A0But for a full-fledg=
ed ISP,
> especially running in a satellite environment or with a lot of dial-u=
p
> customers, it's terrible!

Why?

> That's a reason the Ubuntu configuration approach works for me.
>
> A caveat: I've not run debian directly in many, many years (IIRC, sin=
ce
> Red Hat Colgate), and more recently via Unbuntu (since Badger). =C2=A0=
I don't
> know whether debian has evolved different installation procedures for
> different environments.

I'm not aware of any differences.

> My comments are based on fairly extensive experience with deployment =
of
> Yellow Dog Linux servers at an ISP (as a co-founder), and Ubuntu clie=
nts
> for the past 2 (US) election cycles.

Olaf
