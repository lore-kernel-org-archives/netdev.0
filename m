From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 15:36:35 +0100
Message-ID: <CACT4Y+bbHa64ietEcskKKy_BWf3M0KeTkFMWodK683KtY1yWyg@mail.gmail.com>
References: <56587467.8050102@oracle.com> <1448647077.6523.33.camel@tiscali.nl>
 <56589DD9.2060508@oracle.com> <1448670517.6523.67.camel@tiscali.nl>
 <56590159.4080404@hurleysoftware.com> <5659030C.1070009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Paul Bolle <pebolle@tiscali.nl>, isdn@linux-pingi.de,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34291 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbbK2Og4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 09:36:56 -0500
Received: by wmvv187 with SMTP id v187so123454116wmv.1
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 06:36:55 -0800 (PST)
In-Reply-To: <5659030C.1070009@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 28, 2015 at 2:27 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 11/27/2015 08:20 PM, Peter Hurley wrote:
>> It would really help if you included the syzkaller-generated applet with
>> the bug reports; state previously established by the applet can be
>> crucial in understanding why the call stack looks the way it does.
>>
>> Also, every generated applet that triggers a report should become
>> a future regression test; I'm collecting the ones pertinent to tty/serial/
>> ldisc (so that includes this one; if you could send me the x25 one too
>> would be great).
>
> I went in to look for the 'crashers' that I thought are generated when
> syzkaller manages to crash a kernel, but none appear for me.
>
> Dmitry, is there magic required to generate those?


There is a little bit of magic, but mostly hard muscle labor.
I've outlined how I create reproducers here:
https://github.com/google/syzkaller/wiki/Crash-reproducer-programs
The description is not super detailed, but should be give you some
clue. Ideally it is all automated, but somebody needs to write some
code for that...
