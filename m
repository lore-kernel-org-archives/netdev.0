From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] ppp: allow disabling multilink protocol ID compression
Date: Wed, 22 Dec 2010 09:44:00 +1100
Message-ID: <20101221224400.GA17383@brick.ozlabs.ibm.com>
References: <20101220195833.26786ec5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51432 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522Ab0LUWoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 17:44:10 -0500
Content-Disposition: inline
In-Reply-To: <20101220195833.26786ec5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 07:58:33PM -0800, Stephen Hemminger wrote:

> Linux would not connect to other router running old version Cisco IOS (12.0).
> This is most likely a bug in that version of IOS, since it is fixed
> in later versions. As a workaround this patch allows a module parameter
> to be set to disable compressing the protocol ID.
> 
> See: https://bugzilla.vyatta.com/show_bug.cgi?id=3979
> 
> RFC 1990 allows an implementation to formulate MP fragments as if protocol
> compression had been negotiated.  This allows us to always send compressed
> protocol IDs.  But some implementations don't accept MP fragments with
> compressed protocol IDs.  This parameter allows us to interoperate with
> them.  The default value of the configurable parameter is the same as the
> current behavior:  protocol compression is enabled.  If protocol compression
> is disabled we will not send compressed protocol IDs.
> 
> This is based on an earlier patch by Bob Gilligan (using a sysctl).
> Module parameter is writable to allow for enabling even if ppp
> is already loaded for other uses.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Paul Mackerras <paulus@samba.org>
