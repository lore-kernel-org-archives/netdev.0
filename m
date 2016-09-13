From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
 support
Date: Tue, 13 Sep 2016 11:30:01 -0700
Message-ID: <20160913182959.GA38950@ast-mbp.thefacebook.com>
References: <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com>
 <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160913175926.GA38737@ast-mbp.thefacebook.com>
 <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        William Tu <u9012063@gmail.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33824 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759782AbcIMSaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:30:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id wk8so10052643pab.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:30:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 06:28:03PM +0000, Rustad, Mark D wrote:
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> >I've looked through qemu and it appears only emulate e1k and tg3.
> >The latter is still used in the field, so the risk of touching
> >it is higher.
> 
> I have no idea what makes you think that e1k is *not* "used in the field".
> I grant you it probably is used more virtualized than not these days, but it
> certainly exists and is used. You can still buy them new at Newegg for
> goodness sakes!

the point that it's only used virtualized, since PCI (not PCIE) have
been long dead.
