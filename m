From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH 2.6.8] ipvs - do not use skb_checksum_help
Date: Tue, 17 Aug 2004 13:35:02 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408171334200.10178-100000@dhcp83-76.boston.redhat.com>
References: <Pine.LNX.4.44.0408172344360.1181-100000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0408172344360.1181-100000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004, Wensong Zhang wrote:

> Agree with Julian that there is no need to call skb_checksum_help in IPVS.

What if you have a cloned skb?  It needs to be copied.


- James
-- 
James Morris
<jmorris@redhat.com>
