From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH]  net: mvpp2: fix possible memory leak
Date: Sat, 1 Nov 2014 23:24:45 +0100
Message-ID: <20141101232445.1a3fe27e@free-electrons.com>
References: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47655 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750712AbaKAWYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 18:24:49 -0400
In-Reply-To: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sudip Mukherjee,

On Sat,  1 Nov 2014 16:59:34 +0530, Sudip Mukherjee wrote:
> we are allocating memory using kzalloc for struct mvpp2_prs_entry,
> but later when we are getting error we were just returning the error
> value without releasing the memory.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
> 
> hi,
> i could not build test after modifying it. I tried to compile using
> multi_v7_defconfig , but the cross compiler i have is not able to
> compile it and giving sevaral warnings from the assembler.

That seems weird. Which compiler are you using, and which errors were
you getting?

In any case, it would have been good to Cc the authors of the driver.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
