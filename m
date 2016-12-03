From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2/net-next] ss: initialise variables outside of
 for loop
Date: Sat, 3 Dec 2016 09:37:14 +0100
Message-ID: <20161203083712.GA10228@penelope.horms.nl>
References: <1480679765-9014-1-git-send-email-simon.horman@netronome.com>
 <20161202141817.7341a497@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38685 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbcLCIhT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 03:37:19 -0500
Received: by mail-wm0-f50.google.com with SMTP id f82so34592531wmf.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 00:37:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202141817.7341a497@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:18:17PM -0800, Stephen Hemminger wrote:
> On Fri,  2 Dec 2016 12:56:05 +0100
> Simon Horman <simon.horman@netronome.com> wrote:
> 
> > Initialise for loops outside of for loops. GCC flags this as being
> > out of spec unless C99 or C11 mode is used.
> > 
> > With this change the entire tree appears to compile cleanly with -Wall.
> > 
> > $ gcc --version
> > gcc (Debian 4.9.2-10) 4.9.2
> > ...
> > $ make
> > ...
> > ss.c: In function ‘unix_show_sock’:
> > ss.c:3128:4: error: ‘for’ loop initial declarations are only allowed in C99 or C11 mode
> > ...
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> Applied.

Thanks.

> Note, I used to have -Wall in Makefile but old GCC were broken and would give
> aliasing warnings.

Thanks, good to know.
