From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic netlink interface help
Date: Thu, 24 May 2007 09:21:37 -0400
Message-ID: <200705240921.38015.paul.moore@hp.com>
References: <20070524095654.GA21180@enneenne.com> <31YAj80s.1180001048.5677350.samuel@sortiz.org> <20070524112144.GB21180@enneenne.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rodolfo Giometti <giometti@enneenne.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:35265 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756981AbXEXNWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 09:22:39 -0400
In-Reply-To: <20070524112144.GB21180@enneenne.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 24 2007 7:21:44 am Rodolfo Giometti wrote:
> On Thu, May 24, 2007 at 10:04:08AM -0000, Samuel Ortiz wrote:
> > Yes it's possible, even though it could be more tedious and painful.
>
> I know that. Have you some links to suggest to me in order to have
> some programming examples?

The libnl library itself is probably the best example that I have seen.  At 
it's core it is basically just regular Netlink with an extra layer of 
abstraction, i.e. a new header between the Netlink header and the payload.

Also, if you are still looking for in-kernel examples here are two _very_ 
simple ones which might help:

 * net/netlabel/netlabel_unlabeled.c:netlbl_unlabel_accept()
   This function reads a single attribute, NLBL_UNLABEL_A_ACPTFLG, sent
   from user space and acts on the value.

 * net/netlabel/netlabel_unlabeled.c:netlbl_unlabel_list()
   This function generates a reply message with a single attribute,
   NLBL_UNLABEL_A_ACPTFLG, in response to a request message.

-- 
paul moore
linux security @ hp
