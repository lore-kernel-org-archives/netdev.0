From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: fddi: skfp: use %p format specifier for addresses
 rather than %x
Date: Wed, 21 Dec 2016 09:15:46 -0800
Message-ID: <1482340546.1945.1.camel@perches.com>
References: <20161221160323.27780-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221160323.27780-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-12-21 at 16:03 +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix: Addresses should be printed using the %p format specifier
> rather than using %x.

The DB_TX, DB_RX, DB_GEN, and DB_SMT macros are quite ugly
because they don't match format and argument with __printf
and could be updated quite easily.

Does anyone still use these drivers?
