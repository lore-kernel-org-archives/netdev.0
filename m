From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: strange Mac OSX RST behavior
Date: Fri, 1 Jul 2016 17:04:41 +0100
Message-ID: <20160701170441.51d21d48@lxorguk.ukuu.org.uk>
References: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mac OSX 10.11.5 (latest version), we have found that when tcp
> connections are abruptly terminated (via ^C), a FIN is sent followed
> by an RST packet. The RST is sent with the same sequence number as the
> FIN, and thus dropped since the stack only accepts RST packets matching
> rcv_nxt (RFC 5961). 

The Linux behaviour appears to be correct, and accepting a broken FIN is
most definitely a bad idea, it has a very different effect to a FIN
because there can be data going the other direction and a FIN is a one
way close

Alan
