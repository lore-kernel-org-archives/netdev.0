From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [lec] put back pressure on network stack
Date: Thu, 26 Feb 2004 12:10:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226121036.7472a38a.davem@redhat.com>
References: <200402252354.i1PNs8g5006332@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200402252354.i1PNs8g5006332@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 18:54:09 -0500
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> backport of similar patch for 2.6.  
> 
> please apply to 2.4 -- thanks
 ...
> # [ATM]: [lec] put back pressure on network stack

This conflicts with a previous patch you sent me in this group entitled:

[ATM]: [lec] send queued packets immediately after path switch

So it fully rejected when I tried to apply this one, it looks to me
like the changes this is trying to add are already in there as a result
of the previous change.
