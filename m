From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Network cooling device and how to control NIC speed on thermal
 condition
Date: Mon, 8 May 2017 16:02:25 +0200
Message-ID: <20170508140225.GD19995@lunn.ch>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
 <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk>
 <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
 <20170428115630.GG13231@lunn.ch>
 <CAHKzcENk8USj1kjFco=a+vdXeX-FycM1G4hPm6JnotEUtNi99Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <gnomes@lxorguk.ukuu.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHKzcENk8USj1kjFco=a+vdXeX-FycM1G4hPm6JnotEUtNi99Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> However, the fact is that PHYs having active 1G/s link generate much
> more heat than having 100M/s link independently from network traffic.

Yes, this is true. I got an off-list email suggesting this power
difference is very significant, more so than actually processing
packets.

> All cooling methods impact host only, but "net cooling" impacts remote
> side in addition, which seems to me to be a problem sometimes. Also,
> the moment of link renegotiation blocks rx/tx for upper layers, so the
> user sees a pause when streaming a video for example. However, if a
> system is under a thermal condition, does it really matter?

I don't know the cooling subsystem too well. Can you express a 'cost'
for making a change, as well as the likely result in making the
change. You might want to make the cost high, so it is used as a last
resort if other methods cannot give enough cooling.

       Andrew
