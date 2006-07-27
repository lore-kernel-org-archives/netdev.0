From: "Catalin Marinas" <catalin.marinas@gmail.com>
Subject: Re: RFC: kernel memory leak fix for af_unix datagram getpeersec
Date: Thu, 27 Jul 2006 10:00:23 +0100
Message-ID: <b0943d9e0607270200h250953d7uf58dc9a4f087cb0b@mail.gmail.com>
References: <20060726201916.GA32505@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, sds@tycho.nsa.gov, davem@davemloft.net,
	michal.k.k.piotrowski@gmail.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:45761 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161005AbWG0JAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 05:00:24 -0400
Received: by ug-out-1314.google.com with SMTP id m3so155878ugc
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2006 02:00:23 -0700 (PDT)
To: "Catherine Zhang" <cxzhang@watson.ibm.com>
In-Reply-To: <20060726201916.GA32505@jiayuguan.watson.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/07/06, Catherine Zhang <cxzhang@watson.ibm.com> wrote:
> Enclosed please find the new fix for the memory leak problem, incorporating
> suggestions from Stephen and James.

FYI, Michal confirmed that, with this patch, kmemleak no longer
reports leaks in the context_struct_to_string() function in
security/selinux/ss/services.c. Many thanks to Michal for testing this
(and his constant feedback into kmemleak).

-- 
Catalin
