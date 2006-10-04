From: chunkeey@web.de
Subject: Re: [PATCH] wext
Date: Wed, 4 Oct 2006 12:56:06 +0200
Message-ID: <200610041256.07110.chunkeey@web.de>
References: <200610021955.23112.chunkeey@web.de> <1159951043.2817.36.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chunkeey@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:7893 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1030811AbWJDKzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 06:55:46 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159951043.2817.36.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 10:37, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2006-10-02 at 19:55 +0200, chunkeey@web.de wrote:
> > This patch (wext-patch) is a proposal. It adds two new defines for the
> > SIOCSIWMLME to cover all kinds MLMEs (well, except REASSOC) through a
> > ioctl. (it would be nice to have them, so that I can post the hostapd
> > code for the prism54 card!)
>
> NACK from me. Please help me work on nl80211 instead :)
>
> johannes

hmm... another month of fun. ;) 

no really, the problem is that "my" hardware (aka: prism54 fullmac) does all 
the mac-management, encryption/decryption, AP-Management,... in the firmware. 
And all "management" operation are wrapped into a simple unique 
4-byte "Operation ID"... That's why the WEXT "would be better" for that 
thing...

(Or, do I mix everything up and nl80211 has "nothing" to do with devicescape's 
networkstack d80211?)

	Chr
