From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: nflog performance ...
Date: Wed, 30 Aug 2017 08:37:58 -0700
Message-ID: <20170830083758.611a0a32@xeon-e3>
References: <CAA5aLPj=znm_RDVgPGzZj6VixPdWVMCEVco7yxoa4gL0On+pyg@mail.gmail.com>
        <CAA5aLPjzMd71S-L47G=2pdF+v+SruZ4kEavV03r4datDwdAJ-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33304 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdH3PiB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 11:38:01 -0400
Received: by mail-pf0-f170.google.com with SMTP id r62so20301536pfj.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 08:38:01 -0700 (PDT)
In-Reply-To: <CAA5aLPjzMd71S-L47G=2pdF+v+SruZ4kEavV03r4datDwdAJ-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Aug 2017 13:27:57 +0530
Akshat Kakkar <akshat.1984@gmail.com> wrote:

> Anybody?
> 
> On Tue, Aug 29, 2017 at 4:11 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> > I am using ulogd2 to log iptables activity.
> > However, when using pgsql as output plugin ... performance is very
> > very sluggish. (~130-150 entries per second)
> >
> > To enhance performance I am trying
> >
> > modprobe ipt_ULOG nlbufsiz=65535 flushtimeout=1000
> >
> > but this gives error : ipt_ULOG module not found.
> >
> >
> > On the same lines, I tried
> >
> > modprobe ipt_NFLOG nlbufsiz=65535 flushtimeout=1000
> > It didnt give any error !!!
> >
> > But still there is no increase in performance.
> > Are these values effective?
> >
> > I am also using  --nflog-threshold 50 in iptables rule.
> >
> > I am setting buffer_size as
> > netlink_socket_buffer_size=104857600
> > netlink_socket_buffer_maxsize=1048576000
> >
> > When running ulog, it gives message of setting buffer size as
> > 21708600. Though it didnt give any message like
> > "ulogd_inppkt_NFLOG.c:443 We are losing events, increasing buffer size
> > to xxxxxx"
> > but again why it is only setting buffer size as 21708600 though I have
> > set in config as 104857600?  

Try  the netfilter users mailing list netfilter@vger.kernel.org
