From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: TCP connection issues against Amazon S3
Date: Wed, 7 Jan 2015 02:23:00 +0100
Message-ID: <DUB123-W1008C526C7E0FA115A87EED460@phx.gbl>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no>
 <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no>
 <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no>
 <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
 <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no>
 <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
 <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no>
 <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no>,<3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erik Grinaker <erik@bengler.no>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This still doesn=92t explain why it works with older kernels, but not=
 newer ones.

Can you try the different 3.12-rc kernels? The information that this wa=
s
introduced in 3.12-rc1 as opposed to a specific -rc>1 releases may help
the guys here to pinpoint what exactly caused the behavior change on th=
e
receiver side.

v3.12-rc1 to -rc7 is available as prebuild package on the ubuntu mainli=
ne kernel
archive [1] aswell.


-Lukas


[1] http://kernel.ubuntu.com/~kernel-ppa/mainline/

 		 	   		  --
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
