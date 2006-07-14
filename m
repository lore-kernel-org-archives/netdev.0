From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 14 Jul 2006 19:34:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607141933170.18747@d.namei>
References: <20060714185739.780700000@flek.zko.hp.com>
 <20060714185914.416432000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>, sds@epoch.ncsc.mil,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:59077 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1945914AbWGNXeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 19:34:23 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060714185914.416432000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006, paul.moore@hp.com wrote:


> +static inline void netlbl_put_hdr(unsigned char *buffer,
> +				  const u32 msg_type,
> +				  const u16 msg_len,
> +				  const u16 msg_flags,
> +				  const u32 msg_pid,
> +				  const u32 msg_seq)

Why are these parameters marked const?  Seems to be common throughout the 
code.


- James
-- 
James Morris
<jmorris@namei.org>
