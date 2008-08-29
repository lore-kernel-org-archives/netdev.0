From: "Eugene Teo" <eugeneteo@kernel.sg>
Subject: Re: [PATCH 14/37] dccp: Tidy up setsockopt calls
Date: Fri, 29 Aug 2008 17:25:53 +0800
Message-ID: <28fa9c5e0808290225w1d2a2ff7kf4fb63741780c091@mail.gmail.com>
References: <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.226]:1475 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbYH2JZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 05:25:54 -0400
Received: by qb-out-0506.google.com with SMTP id f11so1428052qba.17
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 02:25:53 -0700 (PDT)
In-Reply-To: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2008 at 1:44 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
[...]
> +       default:
> +               if (optlen < sizeof(int))
> +                       return -EINVAL;

Although it is already checked in sys_setsockopt(), it's probably good
to change this to:

               if (optlen < (int)sizeof(int))
                       return -EINVAL;

Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>

Thanks, Eugene
