From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Tue, 03 Jan 2017 22:54:19 +0100
Message-ID: <1483480459.10534.8.camel@tiscali.nl>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
         <1456945629-1793533-2-git-send-email-arnd@arndb.de>
         <20170103152436.GA26156@kroah.com> <3286019.I2UkVCJq41@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        devel@driverdev.osuosl.org, Karsten Keil <isdn@linux-pingi.de>,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:45539 "EHLO
        lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935360AbdACVy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 16:54:26 -0500
In-Reply-To: <3286019.I2UkVCJq41@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-03 at 22:19 +0100, Arnd Bergmann wrote:
> Sounds good to me. My original series contained four more patches that
> I did not post again after there was some concern[1] that we did not
> come to a conclusion on:
> 
> isdn: gigaset: remove i4l code

Let me repeat that I'm fine with a patch that does that.

> isdn: move isdnhdlc out of i4l
> isdn: i4l: move hisax driver to staging
> isdn: move i4l to staging
> 
> I can post those as well, at least I think the first two are helpful
> for untangling i4l from the rest of ISDN.  I also still think that
> moving hisax and i4l to staging is reasonable given the state of
> that code, even if there are a couple of users today.

There are? And even if there are: is there any reason to expect that moving
the rest of i4l to staging will result in anything other than a stream of
checkpatch cleanups?

How often did a bunch of drivers re-enter the tree after being sent to
staging?


Paul Bolle
