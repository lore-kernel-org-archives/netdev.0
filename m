From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Fri, 24 Feb 2017 10:29:26 -0800
Message-ID: <20170224102926.102b858f@xeon-e3>
References: <20170224101312.31538-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mathias Nyman <m.nyman@iki.fi>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35672 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdBXS3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 13:29:34 -0500
Received: by mail-pg0-f44.google.com with SMTP id b129so14392152pgc.2
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 10:29:34 -0800 (PST)
In-Reply-To: <20170224101312.31538-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Feb 2017 11:13:12 +0100
Petr Vorel <pvorel@suse.cz> wrote:

> COLORFGBG environment variable is used to detect dark background.
> 
> Idea and a bit of code is borrowed from Vim, thanks.
> 
> Signed-off-by: Petr Vorel <pvorel@suse.cz>
> ---
> Colors are nice, but the ones chosen aren't suitable for dark background.
> COLORFGBG environment variable is used in some libraries and software (e.g.
> ncurses, Vim). COLORFGBG is set by various terminal emulators (e.g. konsole,
> rxvt and rxvt-unicode).
> 
> Chosen colors are questionable. Best solution would be also allow user to
> redefine colors, like ls does with LS_COLORS or grep with GREP_COLORS. But that
> is maybe overkill.

This really needs to be standardized with some convention. So that ls, grep, git
all behave the same and done by some standard library.

The current method is hack that keeps on growing.
