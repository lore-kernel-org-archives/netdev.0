From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] HFSC (7) & (8) documentation + assorted changes
Date: Wed, 26 Oct 2011 06:02:10 -0400
Message-ID: <CAJaTeTom1yW_22CbTUa+6iMMpFsomnMhm6-WV0Uft+0FrzjqvQ@mail.gmail.com>
References: <1319616922-18034-1-git-send-email-vapier@gentoo.org> <4EA7D268.1050504@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38054 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932647Ab1JZKCa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 06:02:30 -0400
Received: by iaby12 with SMTP id y12so1555520iab.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 03:02:30 -0700 (PDT)
In-Reply-To: <4EA7D268.1050504@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 05:27, Michal Soltys wrote:
> On 26.10.2011 10:15, Mike Frysinger wrote:
>> I've read it many times over, but it's a lengthy chunk of text - so =
try
>> to be understanding in case I made some mistakes.
>
> TBH, I planned to do some fixes / corrections (minor ones) to the ver=
sion I
> submitted back then, though I had two doubts after looking at it afte=
r a bit
> of time:
>
> - too long / too detailed / hard to read
> =A0(or ITOW, following HFSC paper to closely to be of practical use f=
or
> =A0someone just wanting to know how it works, without [too] gritty
> =A0details)

i think there should be something here about HFSC.  having too much
information in a man page is better than none at all imo.

> - some friendlier format with man export (asciidoc ? yodl ?
> =A0reText ? etc. - not sure what's it the policy regarding iproute2)
> =A0as otherwise it will be quite a burden to maintain / update.

that's orthogonal to the patch i think.  all the iproute2 man pages
are written in roff.  let's keep that sep from getting HFSC
documentation into the tree.

> If my memory serves right, one of the corner cases described in it mi=
ght
> have been fixed by a patch I submitted a good few months ago, though =
I'll
> have to read it to be sure. And there're few other small long-overdue
> patches I'm sitting on (they won't change anything algorithmically, b=
ut at
> least one could be noted in the text - though that can be changed any=
 time
> in the future, and if the patches get accepted at all of course).
>
> Another thing was minor kernel patch to stab, and the docs assumed it=
 was
> added (not sure if you corrected it).

if you want to post updates to the content, i can take care of the
*roff formatting.
-mike
