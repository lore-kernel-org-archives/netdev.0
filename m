From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV4: dead lock in error path
Date: Fri, 21 May 2004 14:40:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521144006.26558046.davem@redhat.com>
References: <20040521.172329.15140532.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040521.172329.15140532.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 May 2004 17:23:29 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> We forgot to release ipip_lock in error path.

Good spotting, applied.
