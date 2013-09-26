From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v6 1/1] xen-netback: Handle backend state
 transitions in a more robust way
Date: Thu, 26 Sep 2013 14:07:33 +0100
Message-ID: <1380200853.29483.83.camel@kazak.uk.xensource.com>
References: <1380193792-9751-1-git-send-email-paul.durrant@citrix.com>
	 <1380193792-9751-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1167 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757071Ab3IZNHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 09:07:36 -0400
In-Reply-To: <1380193792-9751-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 12:09 +0100, Paul Durrant wrote:
> When the frontend state changes netback now specifies its desired state to
> a new function, set_backend_state(), which transitions through any
> necessary intermediate states.
> This fixes an issue observed with some old Windows frontend drivers where
> they failed to transition through the Closing state and netback would not
> behave correctly.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
