From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Don't Process ND Messages with Invalid Options
Date: Thu, 26 Sep 2002 14:31:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926.143131.52117281.davem@redhat.com>
References: <20020925.133031.538200492.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20020925.133031.538200492.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 25 Sep 2002 13:30:31 +0900 (JST)

   Linux happened to process invalid ND messages with invalid options
   such as
    - length of ND options is 0
    - length of ND options is not enough
   Specification says that such messages must be silently discarded.
   This patch parses/checks ND options before it changes state of
   neighbour / address etc. and ignores such messages.
   
   Following patch is against linux-2.4.19.

Patch applied to 2.4.x and 2.5.x, thanks a lot.

Let us hope more patches like this one are coming :-)
