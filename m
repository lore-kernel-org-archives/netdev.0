From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Tue, 7 Nov 2006 15:38:33 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0611071536300.20855@d.namei>
References: <4550BF96.6080709@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:26802 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1753192AbWKGUif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 15:38:35 -0500
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <4550BF96.6080709@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Nov 2006, Venkat Yekkirala wrote:

> Fix SO_PEERSEC for tcp sockets to return the security context of
> the peer (as represented by the SA from the peer) as opposed to the
> SA used by the local/source socket.

What about the case of a localhost TCP connection not using xfrm labeling?

Joe Nall raised this as an important requirement.



(Also, 'mlsxfrm' is MLS-specific).



- James
-- 
James Morris
<jmorris@namei.org>
