From: Mathias Nyman <m.nyman@iki.fi>
Subject: Re: [PATCH v2 net-next] ip: Add color output option
Date: Mon, 20 Apr 2015 23:30:35 +0300
Message-ID: <20150420203035.GA13388@iki.fi>
References: <20150418103945.GA26334@iki.fi>
 <20150420101602.361354d7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, aleksi.aalto@iki.fi
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:45858 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbbDTUai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 16:30:38 -0400
Content-Disposition: inline
In-Reply-To: <20150420101602.361354d7@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for bearing with my first patch.

On 2015-04-20 10:16-0700, Stephen Hemminger wrote:
>On Sat, 18 Apr 2015 13:39:45 +0300
>Mathias Nyman <m.nyman@iki.fi> wrote:
>
>> It is hard to quickly find what you are looking for in the output of
>> the ip
>> command. Color helps.
>>
>> This patch adds a '-c' flag to highlight these with individual colors:
>>    - interface name
>>    - ip address
>>    - mac address
>>    - up/down state
>>
>> Signed-off-by: Mathias Nyman <m.nyman@iki.fi>
>
>I like the idea of this, it would be generally good across the board.
>
>But the patch does not apply cleanly to the current version of iproute2.

What is the current version? I used the net-next branch as a base from
here:
http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git

I thought net-next was used for new features, but master branch now
has newer commits. Should I rebase on top of master?


>And there are minor style issues. iproute2 in general ties to follow kernel style.
>
>WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
>#36:
>new file mode 100644
>
>ERROR: open brace '{' following enum go on the same line
>#45: FILE: include/color.h:5:
>+enum color_attr
>+{
>
>ERROR: open brace '{' following enum go on the same line
>#195: FILE: lib/color.c:7:
>+enum color
>+{
>
>ERROR: that open brace { should be on the previous line
>#207: FILE: lib/color.c:19:
>+static const char * const color_codes[] =
>+{
>
>ERROR: that open brace { should be on the previous line
>#220: FILE: lib/color.c:32:
>+static enum color attr_colors[] =
>+{
>
>ERROR: do not initialise statics to 0 or NULL
>#229: FILE: lib/color.c:41:
>+static int color_is_enabled = 0;
>
>WARNING: Missing a blank line after declarations
>#240: FILE: lib/color.c:52:
>+	va_list args;
>+	va_start(args, fmt);

Thanks, so checkpatch.pl applies to iproute2 as well. I'll fix these in v3.
