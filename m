From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 19:09:52 +0200
Message-ID: <200810121909.53233.rjw@sisk.pl>
References: <200810121315.37203.rjw@sisk.pl> <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com> <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Layton" <jlayton@redhat.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"linux-cifs-client@lists.samba.org"
	<linux-cifs-client@lists.samba.org>, cooldavid@cooldavid.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Steve French" <smfrench@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33722 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753925AbYJLRFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 13:05:43 -0400
In-Reply-To: <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 12 of October 2008, Steve French wrote:
> On Sun, Oct 12, 2008 at 11:53 AM, Steve French <smfrench@gmail.com> wrote:
> > On Sun, Oct 12, 2008 at 8:59 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >> On Sun, 12 Oct 2008 08:40:39 -0500
> >> "Steve French" <smfrench@gmail.com> wrote:
> >>
> >> Actually, I like Adrian/Rafael's fix better. I think we should avoid
> >> cluttering up the code with #ifdef's where possible. key_put() already
> >> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
> >> thing with key_revoke().
> > I don't think it matters much - but we probably shouldn't be
> > overriding global functions.
> 
> To clarify, I like fixing it in keys.h better than overriding it in
> cifs, but in the meantime we need an ifdef in cifs until keys.h
> changes.

Well, adding an empty definition for key_revoke() in the !CONFIG_KEYS case
makes sense anyway IMO.
