From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around the
 skb buff size issue
Date: Mon, 6 Feb 2012 19:32:16 +0100
Message-ID: <CAGsizzKVMHT2TUK2O0odbpm6tkMHq9isSOZcjEies+fOOkURYA@mail.gmail.com>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
 <10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
 <20120203.192933.510206531351047222.davem@davemloft.net> <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
 <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com> <C5551D9AAB213A418B7FD5E4A6F30A0702F806E3@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F806E3@ORSMSX106.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/2/6 Rose, Gregory V <gregory.v.rose@intel.com>:
> That is exactly my approach. =A0We currently have a *bug* in the kern=
el that this patch is addressing. =A0The kernel is attempting to provid=
e too much information for the netlink interface to handle and it's bre=
aking things. =A0So what I want to do is fix the immediate problem whil=
e still providing a way for folks to get the information they need. =A0=
I've accomplished this by doing exactly what Dave asked me to do, provi=
de a filter that defaults to off and then provide a way for the user to=
 request discrete chunks of information in the dump that won't exceed t=
he netlink buffer limits.
>
> The patch is fairly unobtrusive and simple to understand.
>
> I appreciate that it doesn't do all that you'd like to see done and I=
 see no reason why you couldn't go on and develop the extended features=
 that you would like to see, correct? =A0There's nothing in my patch th=
at would prevent that so far as I can tell, although I'm not that famil=
iar with your requirements or proposals yet.
Greg, your patch is completely ok for filtering. I like that thing. I
am just stating that it doesn't eliminate every possible option that
can happen so I believe we should also have method for using cycles -
that's what my patch is doing. So I believe both approaches should be
applied.
