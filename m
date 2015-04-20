From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] ip: Add color output option
Date: Mon, 20 Apr 2015 10:16:02 -0700
Message-ID: <20150420101602.361354d7@urahara>
References: <20150418103945.GA26334@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33359 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbDTRP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 13:15:59 -0400
Received: by paboj16 with SMTP id oj16so212767093pab.0
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 10:15:58 -0700 (PDT)
In-Reply-To: <20150418103945.GA26334@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Apr 2015 13:39:45 +0300
Mathias Nyman <m.nyman@iki.fi> wrote:

> It is hard to quickly find what you are looking for in the output of
> the ip
> command. Color helps.
> 
> This patch adds a '-c' flag to highlight these with individual colors:
>    - interface name
>    - ip address
>    - mac address
>    - up/down state
> 
> Signed-off-by: Mathias Nyman <m.nyman@iki.fi>

I like the idea of this, it would be generally good across the board.

But the patch does not apply cleanly to the current version of iproute2.

And there are minor style issues. iproute2 in general ties to follow kernel style.

WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
#36: 
new file mode 100644

ERROR: open brace '{' following enum go on the same line
#45: FILE: include/color.h:5:
+enum color_attr
+{

ERROR: open brace '{' following enum go on the same line
#195: FILE: lib/color.c:7:
+enum color
+{

ERROR: that open brace { should be on the previous line
#207: FILE: lib/color.c:19:
+static const char * const color_codes[] =
+{

ERROR: that open brace { should be on the previous line
#220: FILE: lib/color.c:32:
+static enum color attr_colors[] =
+{

ERROR: do not initialise statics to 0 or NULL
#229: FILE: lib/color.c:41:
+static int color_is_enabled = 0;

WARNING: Missing a blank line after declarations
#240: FILE: lib/color.c:52:
+	va_list args;
+	va_start(args, fmt);
