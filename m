From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: tracking packets through bridge
Date: Wed, 14 Mar 2007 10:58:28 -0700
Message-ID: <20070314105828.6191fcaf@freekitty>
References: <BAY137-F24034DC7B4E8519C2B0A80FD730@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.osdl.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: "Jie Chen" <cj70286@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47965 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbXCNR6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 13:58:30 -0400
In-Reply-To: <BAY137-F24034DC7B4E8519C2B0A80FD730@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Mar 2007 17:50:50 +0000
"Jie Chen" <cj70286@hotmail.com> wrote:

> Hi,
> 
> 
> 
> I got a question about tracking the packets on bridge. I have a few linux 
> boxes set up with bridge and STP running, which has two interfaces enslaved 
> to the bridge, if I want to send packets from one to another, how do I track 
> which interface I'm using to send packets?
> 
> Thanks,
> 
> Jie

Look at the forwarding table:
	brctl showmacs br0
