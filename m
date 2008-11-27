From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 13:18:47 -0800
Message-ID: <492F0EB7.70308@zytor.com>
References: <492DD792.6080302@linux.intel.com>	<20081127115236.GE29013@elte.hu>	<492EE087.80708@linux.intel.com>	<20081127201836.GA16869@elte.hu> <20081127122800.45fc0b1a@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:43333 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbYK0VTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 16:19:35 -0500
In-Reply-To: <20081127122800.45fc0b1a@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> +	if (!cpu_has_mtrr)
> +		return 0;
>  	if (!is_cpu(INTEL) || disable_mtrr_trim)
>  		return 0;
>  	rdmsr(MTRRdefType_MSR, def, dummy);

cpu_has_mtrr there should presumably replace is_cpu(INTEL).  I'm not 
sure if this can be replaced by use_intel(); in particular use_intel() 
relies on mtrr_if having been initialized.

Looking...

	-hpa (out of town for Thanksgiving)
