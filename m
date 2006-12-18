From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bugme-new] [Bug 7708] New: unregister_netdev() should return
 unregister_netdevice() return code
Date: Mon, 18 Dec 2006 15:50:57 -0800
Message-ID: <20061218155057.1904f666@freekitty>
References: <200612182256.kBIMuVio025766@fire-2.osdl.org>
	<20061218152111.868f9284.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benjamin.li@qlogic.com,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58755 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754777AbWLRXd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 18:33:57 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061218152111.868f9284.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Dec 2006 15:21:11 -0800
Andrew Morton <akpm@osdl.org> wrote:

> On Mon, 18 Dec 2006 14:56:31 -0800
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=7708
> > 
> >            Summary: unregister_netdev() should return unregister_netdevice()
> >                     return code
> >     Kernel Version: 2.6.19.1
> >             Status: NEW
> >           Severity: low
> >              Owner: acme@conectiva.com.br
> >          Submitter: benjamin.li@qlogic.com
> > 
> > 
> > net/core/dev.c:unregister_netdev() function is a wrapper around
> > net/core/dev.c:unregister_netdevice().  The unregister_netdevice() function
> > returns a return code while unregister_netdev() currently does not.  For
> > completeness, we should pass the return code from unregister_netdevice() all the
> > way to the caller.  unregister_netdev() should not swallow the return code.
> > 
> 
> Certainly there's some truth in that ;)
> 
> Is there some reason why you want to test the unregister_netdev() return
> value?
The only return value is -ENODEV, so I would vote for both just being void

-- 
Stephen Hemminger <shemminger@osdl.org>
