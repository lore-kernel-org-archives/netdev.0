From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: 3.8.4 kernel
Date: Tue, 7 May 2013 18:24:59 +0000
Message-ID: <157393863283F442885425D2C45428564F219C97@nasanexd02f.na.qualcomm.com>
References: <5153620E.4010608@gmail.com>
 <CAErSpo6w+tTbwJ7Qinpd0Vx20q5cm2gMvqzE1Do+2=G3b8rcHA@mail.gmail.com>
 <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
 <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com>
 <157393863283F442885425D2C45428564F219B3B@nasanexd02f.na.qualcomm.com>
 <CAErSpo44-f4UdXxO5MdwVg09LFABwFQ320gG8v8jHcYh=5gqvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Joseph A. Millikan" <josephamillikan@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo44-f4UdXxO5MdwVg09LFABwFQ320gG8v8jHcYh=5gqvA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Joseph, if there's no hardware switch for the wireless on your G770, you can
> probably still take wireless out of the picture by removing or renaming the
> bcma module (look in /lib/modules/.../kernel/drivers/bcma/), then rebooting.
> 
> Xiong, do you have a specific network manager-related test that Joseph could
> perform?  I don't want to burden Joseph with a lot of debugging because he's
> currently happy with 3.6.11 and testing is pretty disruptive in his environment.
> 

There is a stranger behavior for this issue: if only enable either one (Ethernet or Wlan), everything looks OK.
But once enable both, the issue arises.

And Misha Labjuk said:
------->
Comment #38 From Misha Labjuk 2013-03-10 21:10:15 (-) [reply] 02:00.0 Ethernet controller: Qualcomm Atheros AR8152 v2.0 Fast Ethernet (rev
c1)

If configured by iproute2 (ip addr add...) stable working.
If NetworkManager running (just running, not managing) - ethernet die after 1-5
min. After "mii-tool -r eth0" working until next freeze.
<------

Unfortunately, I have no idea about NetworkManager :(

BR.
Xiong
