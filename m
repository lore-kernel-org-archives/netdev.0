From: jamal <hadi@cyberus.ca>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Mon, 04 Dec 2006 11:25:02 -0500
Message-ID: <1165249502.3643.9.camel@localhost>
References: <45744016.8080707@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:15687 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937085AbWLDQZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:25:05 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1895970nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 08:25:04 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45744016.8080707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 16:34 +0100, Patrick McHardy wrote:
> Fix a regression from my nfmark mask patch for cls_fw.
> 
> Thomas, Jamal, do you have an idea what this "old method" stuff
> is used for? It seems it is only used during the below mentioned
> race.

AFAIK, that has been there forever. Alexey may know. I am not
sure if removing it will break any scripts etc.

cheers,
jamal

