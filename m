From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 0/4]: Scalable HFSC
Date: Sun, 15 Aug 2004 19:42:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815194223.18896b40.davem@redhat.com>
References: <411E6F49.9030303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, devik@cdi.cz, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <411E6F49.9030303@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 22:00:09 +0200
Patrick McHardy <kaber@trash.net> wrote:

> These 4 patches for 2.4/2.6 make HFSC more scalable by using rbtree's
> instead of sorted lists and an O(1) algorithm for adjusting childrens
> vt-offset. With these patches HFSC with 1024 active sibling classes
> performs only slightly worse (CPU-wise) than HTB. Each change has been
> well tested in tcsim, so I think nothing should break.

All applied, thanks Patrick.
