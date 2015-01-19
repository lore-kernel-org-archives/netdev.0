From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 16:04:21 +0200
Message-ID: <20150119140421.GA1786@angus-think.wlc.globallogic.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
 <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
 <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:54217 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbASOPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:15:09 -0500
Received: by mail-wg0-f54.google.com with SMTP id b13so1901862wgh.13
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 06:15:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 02:57:50PM +0100, Hagen Paul Pfeifer wrote:
> On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> >  misc/ss.c | 362 +++++++++++++++++++++++++++++++++++++++-----------------------
> >  1 file changed, 231 insertions(+), 131 deletions(-)
> 
> Hey Vadin,
> 
> your patch do *not* change the output format, right? ss output is
> parsed by scripts and tools.
> 
> hgn

Hi,

It should not for tcp but does for memory info in the 1st patch where
the memeinfo param names were changed.

Regarding parsing of ss by scripts and tools, thats really painful
for me to see how ss outputs additional info, it is not human readable,
actually I'd like to change the output layout in the future, and add
something like online output option '-O'.

May be you can test these patches if they breaks output parsing ?

Anyway I will give up with ss output changes if we really carrying about
to keep the same output for scripts/tools.

Here are some comments from Stephen:
    http://marc.info/?l=linux-netdev&m=142129033800881&w=2

Regards,
