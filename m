From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 1/2] netpoll: Remove dead netpoll_rx code
Date: Wed, 12 Mar 2014 11:31:57 -0700
Message-ID: <CAM_iQpWL09n2k_KQqNshChssk-iYGJXoRxEuLZDBh164tbJcnA@mail.gmail.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	<87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
	<8738ipf7kn.fsf_-_@xmission.com>
	<1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33260 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145AbaCLSb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 14:31:57 -0400
Received: by mail-ob0-f181.google.com with SMTP id wp4so10416898obc.12
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 11:31:57 -0700 (PDT)
In-Reply-To: <87eh28cvi6.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 1:48 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> To play devil's advocate to my own patch.  Does anyone know where kgdb
> over network (kgdboe) code lives today?
>
> What little I could find in a quick google search strongly suggests that
> kgdboe was abandoned in 2010 or so.
>
> I am trying to figure out if there are any active out of tree projects
> that need by directional netpoll.
>

We simply don't care about out-of-tree modules, they just need to be
merged into upstream for us to care.
