From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Wed, 19 Dec 2012 18:00:03 -0500
Message-ID: <50D246F3.2060603@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <CAASe=fQZGwjM_2PStRE0tje33Doi6TuwJJ3p7x-SRcwq3mQvRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Hasan Chowdhury <shemonc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f178.google.com ([209.85.210.178]:64904 "EHLO
	mail-ia0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751Ab2LSXAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 18:00:22 -0500
Received: by mail-ia0-f178.google.com with SMTP id k25so2323665iah.9
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 15:00:21 -0800 (PST)
In-Reply-To: <CAASe=fQZGwjM_2PStRE0tje33Doi6TuwJJ3p7x-SRcwq3mQvRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12-12-19 10:51 AM, Hasan Chowdhury wrote:
> Hi Jamal,
> I will test it once I get some opportunity , but think I like to know
> even before any  testing
>
> 1. What will be the new procedure to compile iproute2 after the patch
> apply (any new library or any configuration that needs to be adjusted )

git pull Stephens latest tree.
Apply patch 1 and compile.
When you are done compiling an m_xt.so will sit in the tc directory;
unfortunate that we are putting out this shared libs. Backup your distro
version and copy this over to that location. On ubuntu 12.04:
sudo cp tc/m_xt.so /usr/lib/tc/m_xt.so
will do it.

> 2.  tc filter add dev eth0 protocol ip parent 1: prio 3 u32 match ip src
> 192.168.0.0/16 <http://192.168.0.0/16>  flowid 1:1  action xt  -j MARK
> --set-mark 3
>
>
> is this still a valid command ?
>

Indeed it is.

cheers,
jamal
