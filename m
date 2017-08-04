From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] ss: Enclose IPv6 address in brackets
Date: Fri, 04 Aug 2017 13:46:27 -0700
Message-ID: <1501879587.25002.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
         <1aa882d5-b7f6-8b91-b884-0bd45ebeb2a2@der-flo.net>
         <20170804120506.37c6ad60@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Lehner <dev@der-flo.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34931 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdHDUqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:46:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so3680763wra.2
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:46:30 -0700 (PDT)
In-Reply-To: <20170804120506.37c6ad60@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-04 at 12:05 -0700, Stephen Hemminger wrote:
> On Fri, 4 Aug 2017 20:02:52 +0200
> Florian Lehner <dev@der-flo.net> wrote:
> 
> > diff --git a/misc/ss.c b/misc/ss.c
> > index 12763c9..83683b5 100644
> > --- a/misc/ss.c
> > +++ b/misc/ss.c
> > @@ -1046,8 +1046,9 @@ do_numeric:
> > 
> >  static void inet_addr_print(const inet_prefix *a, int port, unsigned
> > int ifindex)
> >  {
> 
> Your email client is wrapping long lines which leads to malformed patch.
> 
> You didn't need buf2, and the code was more complex than it needed to be.
> 
> Rather than waiting for yet another version, I just merged in similar
> code.


Also, is this new format accepted for the filter ?

ss src [::1]:22
