From: akepner@sgi.com
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Fri, 26 Oct 2007 08:55:30 -0700
Message-ID: <20071026155530.GG1114@sgi.com>
References: <200710261721.32019.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andi Kleen <ak@suse.de>,
	Robert.Olsson@data.slu.se
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:59950 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754801AbXJZP4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 11:56:45 -0400
Content-Disposition: inline
In-Reply-To: <200710261721.32019.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 05:21:31PM +0200, Jean Delvare wrote:
> ....
> This is just one way to limit the hash size, there are others; I am not
> familiar enough with the TCP code to decide which is best. Thus, I
> would welcome the proposals of alternatives.
> 

Yeah, the existing way of sizing them is very bad on large systems 
and hardcoding a size sucks (though that's what we do on large 
Altix systems now).

IIRC there was some talk about using a different data structure 
here - something that wouldn't require a fixed size and that 
could maintain reasonably fast lookup even when it got large. 

Robert, has work been done to use TRASH to address this problem? 
Other ideas?

-- 
Arthur

