From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] Fix IPv6 esp mem leak in esp6_input
Date: Sat, 2 Aug 2003 22:56:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030802225619.17d477e3.davem@redhat.com>
References: <200308021350.23342.daniel.ritz@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Ritz <daniel.ritz@gmx.ch>
In-Reply-To: <200308021350.23342.daniel.ritz@gmx.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Aug 2003 13:50:23 +0200
Daniel Ritz <daniel.ritz@gmx.ch> wrote:

> fixes a mem leak in esp6_input() in the error paths. and return -ENOMEM,
> not -EINVAL when out of memory. against 2.6.0-test2-bk

Patch applied, thanks Daniel.
