From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK-PATCH 2.4] IPV6: ensure to evaluate checksum
Date: Thu, 20 May 2004 08:14:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520081421.594c5447.davem@redhat.com>
References: <20040520.193312.19702393.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040520.193312.19702393.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 May 2004 19:33:12 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Following changesets fixes checksum for rawv6 sockets.
>  - don't receive packets with incorrect checksum

I notice now how ipv6 RAW behaves differently here
than ipv4 RAW.  In ipv4, packet is accepted regardless
of checksum correctness.

I can see both advantages and disadvantages of this
behavior.  But what I want to ask is if ipv6 RAW is
being different on purpose, for example does the ipv6
advanced API specify this perhaps?
