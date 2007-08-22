From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 17:26:36 -0400
Message-ID: <200708221726.36783.paul.moore@hp.com>
References: <200708221631.34234.paul.moore@hp.com> <20070822212005.GR32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:51311 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932603AbXHVV0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 17:26:55 -0400
In-Reply-To: <20070822212005.GR32236@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 22 2007 5:20:05 pm Thomas Graf wrote:
> * Paul Moore <paul.moore@hp.com> 2007-08-22 16:31
>
> > We're currently talking about several different ideas to solve the
> > problem, including leveraging the sk_buff.secmark field, and one of the
> > ideas was to add an additional field to the sk_buff structure.  Knowing
> > how well that idea would go over (lead balloon is probably an
> > understatement at best) I started looking at what I might be able to
> > remove from the sk_buff struct to make room for a new field (the new
> > field would be a u32).  Looking at the sk_buff structure it appears that
> > the sk_buff.dev and sk_buff.iif fields are a bit redundant and removing
> > the sk_buff.dev field could free 32/64 bits depending on the platform. 
> > Is there any reason (performance?) for keeping the sk_buff.dev field
> > around?  Would the community be open to patches which removed it and
> > transition users over to the sk_buff.iif field?  Finally, assuming the
> > sk_buff.dev field was removed, would the community be open to adding a
> > new LSM/SELinux related u32 field to the sk_buff struct?
>
> This reminds of an idea someone brought up a while ago, it involved
> having a way to attach additional space to an sk_buff for all the
> different marks and other non-essential fields.

Interesting.  Was it just a thought, or was there some actual 
design/code/patchset to go along with it that described the idea?

-- 
paul moore
linux security @ hp
