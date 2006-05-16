From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re:
Date: Tue, 16 May 2006 09:34:01 -0300
Message-ID: <39e6f6c70605160534s752676c0wa88121e9eef7cae8@mail.gmail.com>
References: <EA629E23-98F8-4CB0-96B0-259C2A30BDFF@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "kernel list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, grsecurity@grsecurity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:14955 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751810AbWEPMeD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 08:34:03 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1000673ugc
        for <netdev@vger.kernel.org>; Tue, 16 May 2006 05:34:01 -0700 (PDT)
To: "Chris Boot" <bootc@bootc.net>
In-Reply-To: <EA629E23-98F8-4CB0-96B0-259C2A30BDFF@bootc.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/16/06, Chris Boot <bootc@bootc.net> wrote:
> Hi,
>
> I've just seen the following assertions pop out of one of my servers
> running 2.6.16.9 with grsecurity. I've searched the archives of LKML
> and netdev and I've only found posts relating to 2.6.9, after which
> some related bugs were fixed... It looks like these bugs are related
> to e1000, which is the driver I'm using. The system was running 24
> days before these appeared and it's still running absolutely fine.
>
> May 16 09:15:12 baldrick kernel: [6442250.504000] KERNEL: assertion (!
> sk->sk_forward_alloc) failed at net/core/stream.c (283)
> May 16 09:15:12 baldrick kernel: [6442250.513000] KERNEL: assertion (!
> sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)
>
> baldrick bootc # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on

I guess just disable TSO or use latest kernel from git, it has a fix for this.

- Arnaldo
