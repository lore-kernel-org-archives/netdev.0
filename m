From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] dccp: Implement both feature-local and
 feature-remote Sequence Window feature
Date: Sun, 18 Jan 2009 21:40:08 -0800 (PST)
Message-ID: <20090118.214008.48843135.davem@davemloft.net>
References: <1232184993-9927-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1232184993-9927-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1232184993-9927-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755387AbZASFkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:40:06 -0500
In-Reply-To: <1232184993-9927-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 10:36:31 +0100

> This adds full support for local/remote Sequence Window feature, from which the 
>   * sequence-number-validity (W) and 
>   * acknowledgment-number-validity (W') windows 
> derive as specified in RFC 4340, 7.5.3. 
> 
> Specifically, the following is contained in this patch:
>   * integrated new socket fields into dccp_sk;
>   * updated the update_gsr/gss routines with regard to these fields;
>   * updated handler code: the Sequence Window feature is located at the TX side,
>     so the local feature is meant if the handler-rx flag is false;
>   * the initialisation of `rcv_wnd' in reqsk is removed, since
>     - rcv_wnd is not used by the code anywhere;
>     - sequence number checks are not done in the LISTEN state (cf. 7.5.3);
>     - dccp_check_req checks the Ack number validity more rigorously;
>   * the `struct dccp_minisock' became empty and is now removed.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied for 2.6.30
