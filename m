From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial
 XDP support
Date: Tue, 13 Sep 2016 19:14:27 +0000
Message-ID: <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
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
 <20160913182959.GA38950@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_8980034D-560E-4F0D-92E8-42EC875C9036";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        William Tu <u9012063@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:16095 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755214AbcIMTPR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 15:15:17 -0400
In-Reply-To: <20160913182959.GA38950@ast-mbp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_8980034D-560E-4F0D-92E8-42EC875C9036
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Sep 13, 2016 at 06:28:03PM +0000, Rustad, Mark D wrote:
>> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>
>>> I've looked through qemu and it appears only emulate e1k and tg3.
>>> The latter is still used in the field, so the risk of touching
>>> it is higher.
>>
>> I have no idea what makes you think that e1k is *not* "used in the field".
>> I grant you it probably is used more virtualized than not these days,  
>> but it
>> certainly exists and is used. You can still buy them new at Newegg for
>> goodness sakes!
>
> the point that it's only used virtualized, since PCI (not PCIE) have
> been long dead.

My point is precisely the opposite. It is a real device, it exists in real  
systems and it is used in those systems. I worked on embedded systems that  
ran Linux and used e1000 devices. I am sure they are still out there  
because customers are still paying for support of those systems.

Yes, PCI(-X) is absent from any current hardware and has been for some  
years now, but there is an installed base that continues. What part of that  
installed base updates software? I don't know, but I would not just assume  
that it is 0. I know that I updated the kernel on those embedded systems  
that I worked on when I was supporting them. Never at the bleeding edge,  
but generally hopping from one LTS kernel to another as needed.

The day is coming when all the motherboards with PCI(-X) will be gone, but  
I think it is still at least a few years off.
--Apple-Mail=_8980034D-560E-4F0D-92E8-42EC875C9036--
