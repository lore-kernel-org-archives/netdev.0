From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] net: cleanup miss usage of seq_release_private
Date: Wed, 7 Jul 2004 14:10:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707141056.110e7db8.davem@redhat.com>
References: <871xjnmxex.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <871xjnmxex.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 08 Jul 2004 04:26:14 +0900
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:

> These doesn't allocate memory and doesn't use seq->private. However
> kfree() ignores NULL, so these are not the problem.
> 
> This patch just cleans these up.

Patch applied, thanks.
