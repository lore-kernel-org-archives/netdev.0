From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 2 Feb 2012 17:52:04 -0500
Message-ID: <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	<1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	<1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328203710.5553.94.camel@leeds.uk.xensource.com>
	<1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328212761.28964.77.camel@dagon.hellion.org.uk>
	<1328214866.2480.18.camel@edumazet-laptop>
	<1328215821.13189.24.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45686 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab2BBWwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 17:52:06 -0500
Received: by ghrr11 with SMTP id r11so1449131ghr.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 14:52:05 -0800 (PST)
In-Reply-To: <1328215821.13189.24.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 3:50 PM, Ian Campbell <Ian.Campbell@citrix.com> =
wrote:
> On Thu, 2012-02-02 at 20:34 +0000, Eric Dumazet wrote:

[...]

>
> I don't think it is at all unreasonable to ask for bug fixes but in t=
his
> case Wei's series is removing the code in question (which would also
> undoubtedly fix the bug).
>
> As it happens the fix turns out to be simple but if it were complex I
> would perhaps have disagreed more strongly about spending effort fixi=
ng
> code that is removed 2 patches later, although obviously that would h=
ave
> depended on the specifics of the fix in that case.

Lots of people are relying on git bisect.  If you introduce build failu=
res
or known bugs into any point in history, you take away from the value
in git bisect.  Sure, it happens by accident, but it shouldn't ever be
done knowingly.

Paul.

>
>> Next time, dont bother send patches for review if you dont want
>> reviewers.
>
> The review which you are doing is certainly very much appreciated, I'=
m
> sorry if my disagreement over this one point gave/gives the impressio=
n
> that it is not.
>
> Ian.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
