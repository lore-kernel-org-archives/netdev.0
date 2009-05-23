From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Sat, 23 May 2009 02:04:37 +0100
Message-ID: <1243040677.16597.52.camel@deadeye>
References: <1243004704.3192.21.camel@achroite>
	 <20090522171850.GA16751@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53104 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753764AbZEWBEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 21:04:45 -0400
In-Reply-To: <20090522171850.GA16751@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-22 at 10:18 -0700, Chaitanya Lala wrote:
> The MDI-X status is a useful tool for diagnosing network
> connectivity issues. We expose MDI-X status as a tri-state value
> status which drivers can optionally implement.
> 
> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  ethtool-copy.h |    6 ++++++
>  ethtool.c      |   13 +++++++++++++
>  2 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 3ca4e2c..d3e1524 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -28,6 +28,7 @@ struct ethtool_cmd {
>  	__u16	speed_hi;
>  	__u16	reserved2;
>  	__u32	reserved[3];
> +	__u8	is_mdix;	/* Tri-state value to expose MDI-X */
>  };
[...]

No, you cannot change the size of this structure either.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
