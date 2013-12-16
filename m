From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 3/3] packet: Deliver VLAN TPID to userspace
Date: Mon, 16 Dec 2013 09:25:09 -0800
Message-ID: <20131216092509.1b3d76b3@nehalam.linuxnetplumber.net>
References: <87mwk16wpy.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	"David Laight" <David.Laight@ACULAB.COM>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55264 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab3LPRZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 12:25:13 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so5599604pdj.37
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 09:25:13 -0800 (PST)
In-Reply-To: <87mwk16wpy.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Dec 2013 17:12:09 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

>  struct tpacket_hdr_variant1 {
>  	__u32	tp_rxhash;
>  	__u32	tp_vlan_tci;
> +	__u32	tp_vlan_tpid;
>  };

Is this safe? Won't you break ABI for existing userspace applications.
