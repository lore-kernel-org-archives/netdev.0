From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Thu, 17 Jul 2003 04:38:00 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170038.EAA12945@dub.inr.ac.ru>
References: <3F15E86F.2030707@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com (Krishna Kumar)
In-Reply-To: <3F15E86F.2030707@us.ibm.com> from "Krishna Kumar" at Jul 16, 2003 05:06:07 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This is sort of what I had originally, so I should be able to change
> it to do this quite easily. I didn't like the earlier suggestion of
> using existing RTM_xxxLINK with RTM_xxxIFACE (since it was dev generic),
> but having a new interface RTM_xxxIFACE sounds good to me.

Actually, the original plan was to use ifli_family to query something
or to direct a request to a specific interface on some netdevice.
I wanted to reserve IFLI_PROTINFO attribute to encapsulate information
private for specific family. It was not realized mostly because of absense
of such information.

Maybe, you will want to resurrect this.

Alexey
