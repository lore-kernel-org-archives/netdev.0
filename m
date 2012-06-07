From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Thu, 7 Jun 2012 16:47:26 -0400
Message-ID: <4FD1135E.1050502@tilera.com>
References: <4FCFA312.4020505@tilera.com> <20120606.115440.1245419453265419850.davem@davemloft.net> <201206072031.q57KV0NG029301@farm-0023.internal.tilera.com> <20120607.133900.1764130639940088009.davem@davemloft.net> <4FD11292.10700@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <bhutchings@solarflare.com>,
	<arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FD11292.10700@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/7/2012 4:44 PM, Chris Metcalf wrote:
> On 6/7/2012 4:39 PM, David Miller wrote:
>> From: Chris Metcalf <cmetcalf@tilera.com>
>> Date: Fri, 6 Apr 2012 16:42:03 -0400
>>
>>> Date: Fri, 6 Apr 2012 16:42:03 -0400
>> You did not commit this file on April 6th.
>>
>> Please don't use the date emitted by the GIT tools, just
>> let the email use the natural correct date which is the
>> one at the time you send the email out.
>>
>> Otherwise your patch gets misordered as automated tools like
>> patchwork think this file should go all the way at the back
>> of the patch queue because of it's old date relative to
>> other pending patches.
> Yes, when I use "git rebase" to merge changes into the earlier patch, this
> is the behavior I see.  I don't know if there's some way to tell git to
> take the date on the later change instead when I "squash" them.  Or if,
> perhaps, there is some other workflow I should be using.  It does seem like
> the git history should reflect the latest time.
>
> The issue of the date on the email is separate.  I tend to use "git
> format-patch" to start with, munge up the headers to jam in some
> "In-Reply-To" and "References" lines, manually update the "Date:", then
> feed it to "sendmail -t".  Perhaps there's a different workflow I should be
> using there, too.  (I tried deleting the "Date", but the one time I tried
> that I ended up with some surprisingly bogus date in the email that hit
> LKML, so I've been avoiding that approach.)
>
> I'll resend the patch without a Date: line and see how it ends up this time.

Well, I see where the sendmail "Date:" weirdness was coming from; for some
reason "git format-patch" was emitting a first line like this: "From
4d76049b3a48f1b32aed1eeb17b4d3a2cb1b1ff6 Mon Sep 17 00:00:00 2001", and
sendmail was helpfully pulling the "Date:" line from there.  Deleting that
line as well does the right thing, as I see from the third version of this
patch on LKML.  Why git is doing this is a good question.

Sorry for the spam, but hopefully that will avoid the issue in the future.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
