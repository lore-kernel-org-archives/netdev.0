From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix wrong sizeof
Date: Fri, 02 Oct 2009 09:54:02 -0700 (PDT)
Message-ID: <20091002.095402.42770342.davem@davemloft.net>
References: <20091002113038.1dc3d284@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, rdunlap@xenotime.net, stable@kernel.org
To: khali@linux-fr.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20091002113038.1dc3d284@hyperion.delvare>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <khali@linux-fr.org>
Date: Fri, 2 Oct 2009 11:30:38 +0200

> Which is why I have always preferred sizeof(struct foo) over
> sizeof(var).
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Cc: Randy Dunlap <rdunlap@xenotime.net>

Any time you see "&" in a sizeof() expression, it's almost
certainly a bug.  Something for the folks with automated
tools to look for if they haven't already :-)

I'll apply this, thanks.
