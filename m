From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_unix: Fix path of /proc/net/unix
Date: Sun, 8 Feb 2004 13:07:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208130700.4e225134.davem@redhat.com>
References: <878yjf2wx7.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <878yjf2wx7.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 16:03:48 +0900
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:

> We should overwrite the first "nul" by "@" in the case of abstract
> path, otherwise currently "netstat -x" can't print, at least.  And
> normal one, odd "nul" was added.
> 
> This patch does behavior of 2.4. Please apply.

Applied, thanks.
