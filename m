From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add VF_PORT support
Date: Tue, 9 Nov 2010 14:22:19 -0800
Message-ID: <20101109142219.0166576a@nehalam>
References: <20101109222011.23322.24678.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, scofeldm@cisco.com,
	arnd@arndb.de
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42755 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753497Ab0KIWWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 17:22:21 -0500
In-Reply-To: <20101109222011.23322.24678.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 09 Nov 2010 14:20:11 -0800
Roopa Prabhu <roprabhu@cisco.com> wrote:

> 			response == PORT_VDP_RESPONSE_SUCCESS ?
> +				"SUCCESS" :
> +			response == PORT_VDP_RESPONSE_INVALID_FORMAT ?
> +				"INVALID FORMAT" :
> +			response == PORT_VDP_RESPONSE_INSUFFICIENT_RESOURCES ?
> +				"INSUFFICIENT RESOURCES" :
> +			response == PORT_VDP_RESPONSE_UNUSED_VTID ?
> +				"UNUSED VTID" :
> +			response == PORT_VDP_RESPONSE_VTID_VIOLATION ?
> +				"VTID VIOLATION" :
> +			response == PORT_VDP_RESPONSE_VTID_VERSION_VIOALTION ?
> +				"VTID VERSION VIOLATION" :
> +			response == PORT_VDP_RESPONSE_OUT_OF_SYNC ?
> +				"OUT-OF-SYNC" :
> +			response == PORT_PROFILE_RESPONSE_SUCCESS ?
> +				"SUCCESS" :
> +			response == PORT_PROFILE_RESPONSE_INPROGRESS ?
> +				"IN-PROGRESS" :
> +			response == PORT_PROFILE_RESPONSE_INVALID ?
> +				"INVALID" :
> +			response == PORT_PROFILE_RESPONSE_BADSTATE ?
> +				"BAD STATE" :
> +			response == PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES ?
> +				"INSUFFICIENT RESOURCES" :
> +			response == PORT_PROFILE_RESPONSE_ERROR ?
> +				"ERROR" :
> +			"UNKNOWN RESPONSE");

That's an ugly way to do this.
Make it a real function nor array.

-- 
