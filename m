From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH net-next-2.6] net: introduce a macro to traverse
 through uc_list easily
Date: Sat, 23 Jan 2010 02:01:40 -0800 (PST)
Message-ID: <20100123.020140.231150448.davem@davemloft.net>
References: <20100122151301.GC2609@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jpirko@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754706Ab0AWKBb@vger.kernel.org>
In-Reply-To: <20100122151301.GC2609@psychotron.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 22 Jan 2010 16:13:02 +0100

> Therefore that would be good to introduce a macro that can be used to traverse
> through addresses in the list without caller knowing anything about the type of
> the list. I think this kind of an abstraction is appropriate on this place.
> Also during the phase of changing, the macro can use the original list and onc ...
> What do you think about this? Please comment.

Yes this is the way to do it, three steps:

1) Add interface macros that iterate using the existing
   datastructure

2) Convert drivers to use #1

3) Convert to list_head
