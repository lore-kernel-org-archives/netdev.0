From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Wed, 07 Jan 2015 13:33:21 -0800
Message-ID: <1420666401.5947.35.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no>
	 <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
	 <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com>
	 <34CE0233-F881-4F40-B119-AA9D8F7D500F@bengler.no>
	 <1420646284.5947.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erik Grinaker <erik@bengler.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-07 at 20:37 +0000, Erik Grinaker wrote:

> I agree. I have contacted Amazon about this, but am not too hopeful
> for a quick fix; they have been promising SACK-support on their
> loadbalancers since 2006, for example.
> 
> That said, since this change breaks a service as popular as S3, it
> might be worth reconsidering.
> 

Which change are you talking about ? Have you done a bisection to
clearly identify the patch exposing this sender bug ?

We are not going to stick TCP stack to 20th century and buggy peers or
middleboxes, sorry.
