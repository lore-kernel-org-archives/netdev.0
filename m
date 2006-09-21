From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/6] NetLabel: correct improper handling of non-NetLabel
 peer contexts
Date: Thu, 21 Sep 2006 14:08:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609211406030.7534@d.namei>
References: <20060921165703.251871000@hp.com> <20060921170335.013411000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, sds@epoch.ncsc.mil,
	jmorris@redhat.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:690 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751425AbWIUSIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 14:08:16 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060921170335.013411000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Sep 2006, paul.moore@hp.com wrote:

> Fix a problem where NetLabel would always set the value of 
> sk_security_struct->peer_sid in selinux_netlbl_sock_graft() to the context of
> the socket, causing problems when users would query the context of the
> connection.  This patch fixes this so that the value in
> sk_security_struct->peer_sid is only set when the connection is NetLabel based,
> otherwise the value is untouched.

I'll let Thomas comment on the Netlink changes, as he's been working with 
you on them.

These changes otherwise seem ok.  How much testing has this had with and 
without Netlabel enabled?



- James
-- 
James Morris
<jmorris@namei.org>
