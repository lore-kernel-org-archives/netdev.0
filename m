From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gianfar: Fix possible overrun and simplify
 interrupt name field creation
Date: Sun, 25 Mar 2012 13:29:13 -0400 (EDT)
Message-ID: <20120325.132913.1085823688400645918.davem@davemloft.net>
References: <CAP=VYLrPbYv2C7hYaQ-aUJLFCfYh5zkJzFXJt8GFV2OTZ7h=og@mail.gmail.com>
	<1332695407-21167-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	afleming@freescale.com, joe@perches.com
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332695407-21167-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 25 Mar 2012 13:10:07 -0400

> From: Joe Perches <joe@perches.com>
> 
> Space allocated for int_name_<foo> is insufficient for
> maximal device name, expand it.
> 
> Code to create int_name_<foo> is obscure, simplify it
> by using sprintf.
> 
> Found by looking for unnecessary \ line continuations.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Tested-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
