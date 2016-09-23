From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 22:57:42 +0300
Message-ID: <20160923225742.049c0703@halley>
References: <1474649699-31069-1-git-send-email-lrichard@redhat.com>
        <20160923220036.55d469b0@halley>
        <745948754.3473250.1474660344493.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34875 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757894AbcIWT5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 15:57:49 -0400
Received: by mail-wm0-f43.google.com with SMTP id l132so50914204wmf.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 12:57:48 -0700 (PDT)
In-Reply-To: <745948754.3473250.1474660344493.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 15:52:24 -0400 (EDT) Lance Richardson <lrichard@redhat.com> wrote:
> > From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> > Suggesting to add:
> > 
> > Up until now, 'ip6gre_xmit_other' has set flowi6_proto to a bogus value.
> > This affects output route lookup upon xmit of non ipv4/ipv6 packets on a
> > ip6gretap device, in cases where routing depends on flowi6_proto.
> >   
> 
> Added in v2, taking some editorial license (please let me know if I mangled it
> too badly).

Thanks Lance, looks good.
