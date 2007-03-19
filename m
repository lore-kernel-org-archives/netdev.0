From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Mon, 19 Mar 2007 14:23:55 -0400
Message-ID: <20070319182355.GC22467@csclub.uwaterloo.ca>
References: <20070220144823.GN7585@csclub.uwaterloo.ca> <20070315.143939.193680310.takada@mbf.nifty.com> <20070315173137.GJ22466@csclub.uwaterloo.ca> <20070317.220810.208970218.takada@mbf.nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takada <takada@mbf.nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:42858 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932642AbXCSSX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 14:23:58 -0400
Content-Disposition: inline
In-Reply-To: <20070317.220810.208970218.takada@mbf.nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 17, 2007 at 10:08:10PM +0900, takada wrote:
> I tested some patterns. just X86_OOSTORE was effective. WBINVD is needless.
> 
> --- arch/i386/Kconfig.cpu~	2007-02-05 03:44:54.000000000 +0900
> +++ arch/i386/Kconfig.cpu	2007-02-17 21:25:52.000000000 +0900
> @@ -322,7 +322,7 @@ config X86_USE_3DNOW
>  
>  config X86_OOSTORE
>  	bool
> -	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR
> +	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR || MGEODEGX1
>  	default y
>  
>  config X86_TSC

Well that is exactly what I did for the Geode SC1200 (a GX1 based
design) as well and it certainly improved things a lot for me as well.

--
Len Sorensen
