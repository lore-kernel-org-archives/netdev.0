From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Always remove the correct address selector
Date: Wed, 22 Apr 2009 00:46:33 -0700 (PDT)
Message-ID: <20090422.004633.124805299.davem@davemloft.net>
References: <20090421200422.10106.24767.stgit@flek.lan>
	<49EEB139.2050309@numericable.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: etienne.basset@numericable.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <49EEB139.2050309@numericable.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Etienne Basset <etienne.basset@numericable.fr>
Date: Wed, 22 Apr 2009 07:55:05 +0200

> Hi,
> 
> Paul Moore wrote:
>> The NetLabel address selector mechanism has a problem where it can get
>> mistakenly remove the wrong selector when similar addresses are used.  The
>> problem is caused when multiple addresses are configured that have different
>> netmasks but the same address, e.g. 127.0.0.0/8 and 127.0.0.0/24.  This patch
>> fixes the problem.
> 
> thanks Paul!
> 
> Tested-by: Etienne Basset <etienne.basset@numericable.fr>

Applied, thanks everyone.
