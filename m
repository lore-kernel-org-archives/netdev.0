From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: [PATCH 7/7] netfilter: add user-space connection tracking helper infrastructure
Date: Wed, 06 Jun 2012 11:39:26 +0200
Message-ID: <87396893u9.fsf@szonett.ki.iif.hu>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
	<1338812485-4232-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	wferi@niif.hu
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338812485-4232-8-git-send-email-pablo@netfilter.org>
	(pablo@netfilter.org's message of "Mon, 4 Jun 2012 14:21:25 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pablo@netfilter.org writes:

> * Security: Avoid complex string matching and mangling in kernel-space
>   running in unprivileged mode.

Or rather in privileged mode?

> 2) Add rules to enable the FTP user-space helper which is
>    used to track traffic going to TCP port 10000.

The examples use port 21 in the iptables commands and the expectations:

>  iptables -I OUTPUT -t raw -p tcp --dport 21 -j CT --helper ftp
>  iptables -I PREROUTING -t raw -p tcp --dport 21 -j CT --helper ftp
>
>     [NEW] 301 proto=6 src=192.168.1.136 dst=130.89.148.12 sport=0 dport=54037 mask-src=255.255.255.255 mask-dst=255.255.255.255 sport=0 dport=65535 master-src=192.168.1.136 master-dst=130.89.148.12 sport=57127 dport=21 class=0 helper=ftp
> [DESTROY] 301 proto=6 src=192.168.1.136 dst=130.89.148.12 sport=0 dport=54037 mask-src=255.255.255.255 mask-dst=255.255.255.255 sport=0 dport=65535 master-src=192.168.1.136 master-dst=130.89.148.12 sport=57127 dport=21 class=0 helper=ftp
-- 
Regards,
Feri.
