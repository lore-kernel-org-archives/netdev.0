From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
 support
Date: Wed, 14 Sep 2016 01:17:24 +0200
Message-ID: <20160913231724.GA14757@electric-eye.fr.zoreil.com>
References: <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160913175926.GA38737@ast-mbp.thefacebook.com>
 <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
 <20160913182959.GA38950@ast-mbp.thefacebook.com>
 <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42076 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932517AbcIMXRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 19:17:44 -0400
Content-Disposition: inline
In-Reply-To: <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rustad, Mark D <mark.d.rustad@intel.com> :
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
[...]
> > the point that it's only used virtualized, since PCI (not PCIE) have
> > been long dead.
> 
> My point is precisely the opposite. It is a real device, it exists in real
> systems and it is used in those systems. I worked on embedded systems that
> ran Linux and used e1000 devices. I am sure they are still out there because
> customers are still paying for support of those systems.

Old PCI is not the bulk of my professional hardware but it's still used here,
both for networking and video. No embedded systems. Mostly dumb file serving
ranging from quad core to i5 and xeon. Recent kernels. 

> The day is coming when all the motherboards with PCI(-X) will be gone, but I
> think it is still at least a few years off.

Add some time for the PCI <-> PCIe adapters to disappear as well. :o)

-- 
Ueimor
